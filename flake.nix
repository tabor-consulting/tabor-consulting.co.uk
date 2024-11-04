{
  description = "website for tabor consulting";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];

      pkgsForSystem = system: (import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (
        system:
        let
          inherit (pkgsForSystem system)
            buildEnv
            buildGo122Module
            cacert
            dockerTools
            hugo
            lib
            ;
          version = self.shortRev or (builtins.substring 0 7 self.dirtyRev);
          rev = self.rev or self.dirtyRev;
        in
        {
          default = self.packages.${system}.tabor-consulting;

          tabor-consulting = buildGo122Module {
            inherit version;
            pname = "tabor-consulting";
            src = lib.cleanSource ./.;

            vendorHash = "sha256-ndA+beGcp+mcl3Uopb3ltqv5UPMCvBm+V2qqII4uFYw=";

            buildInputs = [ cacert ];
            nativeBuildInputs = [ hugo ];

            # Generate the Hugo site before building the Go application which embeds the
            # built site.
            preBuild = ''
              go generate ./...
            '';

            ldflags = [ "-X main.commit=${rev}" ];

            # Rename the main executable in the output directory
            postInstall = ''
              mv $out/bin/tabor-consulting.co.uk $out/bin/tabor-consulting
            '';

            meta.mainProgram = "tabor-consulting";
          };

          tabor-consulting-container = dockerTools.buildImage {
            name = "jnsgruk/tabor-consulting";
            tag = version;
            created = "now";
            copyToRoot = buildEnv {
              name = "image-root";
              paths = [
                self.packages.${system}.tabor-consulting
                cacert
              ];
              pathsToLink = [
                "/bin"
                "/etc/ssl/certs"
              ];
            };
            config = {
              Entrypoint = [ "${lib.getExe self.packages.${system}.tabor-consulting}" ];
              Expose = [
                8080
                8801
              ];
              User = "10000:10000";
            };
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = pkgsForSystem system;
        in
        {
          default = pkgs.mkShell {
            name = "tabor-consulting";
            NIX_CONFIG = "experimental-features = nix-command flakes";
            nativeBuildInputs = with pkgs; [
              go_1_23
              go-tools
              gofumpt
              gopls
              hugo
              flyctl
              zsh
            ];
            shellHook = "exec zsh";
          };
        }
      );
    };
}

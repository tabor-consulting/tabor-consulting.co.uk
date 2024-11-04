# tabor-consulting.co.uk

This repository contains the code for https://tabor-consulting.co.uk.

## Building

This project is packaged with Nix, both as a standard Nix package and an OCI container:

```shell
# Build the Nix package for the site
nix build .#tabor-consulting

# Build the OCI image
nix build .#tabor-consulting-container

# Load the container into Docker, and run
docker load < result
# The image tag will the commit short hash
docker run --rm -p 8080:8080 -p 8081:8081 "tabor-consulting/tabor-consulting.co.uk:$(git rev-parse --short HEAD)"
```

To build and serve just the Hugo site during development:

```shell
# Optional: enter a shell with all the dependencies present.
nix develop

cd site
hugo serve
```

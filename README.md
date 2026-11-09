# tabor-consulting.co.uk

This repository contains the code for https://tabor-consulting.co.uk.
The site is built with [Hugo](https://gohugo.io), served by
[gosherve](https://github.com/jnsgruk/gosherve), and deployed to Fly.io.

## Development

Install [Canonical Workshop](https://github.com/canonical/workshop) and configure LXD
using the [setup guide](https://documentation.ubuntu.com/canonical-workshop/stable/tutorial/part-1-get-started/),
then run:

```shell
workshop launch
workshop run -- build
workshop run -- dev
```

The development server is available at http://localhost:1313.
Use `workshop run -- generate` to generate the site without building the binary,
or `workshop shell` for an interactive environment. Actions pass through arguments,
for example `workshop run -- dev --disableFastRender`.

The Store Go SDK supplies Go 1.27 and gopls. Project SDKs in `.workshop/`
install gofumpt, Hugo extended, Dart Sass, and flyctl. Hugo uses the upstream extended binary
to access Workshop's `/project` mount and compile the theme's Sass.
Run `workshop refresh` after changing SDK definitions or setup hooks.

## Theme

Colordrop is vendored unchanged at `v2.0.0-alpha.6`, commit
`8820f34752e6e34edf0ff53278d7cdfad3d97dce`, from
[humrochagf/colordrop](https://github.com/humrochagf/colordrop/tree/v2.0.0-alpha.6).
Keep upstream files in `site/themes/colordrop` unchanged when updating the theme.

Site customisations live in `site/assets/sass` and `site/layouts`: the colour,
typography and logo styles; the home page content; and the footer. The base
template omits upstream's Pagefind search UI and scripts because this site does
not build a search index. `params.custom_css` loads `site/static/overrides.css`.

`site/content/pages/_index.md` disables the unused section index while keeping
individual pages available. Styles compile with Dart Sass, installed by
`.workshop/hugo/scripts/install-dart-sass` in both Workshop and Rockcraft. The compiler is pinned
to 1.108.1 with archive checksums. Colordrop still uses legacy Sass imports and
color functions, so the base template suppresses import and dependency deprecation
notices until upstream migrates. Project Sass uses modern color functions.
Review the compiler pin and warning options when updating Colordrop.
Both build environments use the upstream Hugo archive via `.workshop/hugo/scripts/install-hugo`
so Hugo uses the separately installed Dart Sass compiler.
Workshop setup hooks use the SDK bundle via `$SDK`, because `/project` is not
mounted during `setup-base`.

## Container image

Build the OCI image with [Rockcraft](https://documentation.ubuntu.com/rockcraft/):

```shell
rockcraft pack
```

The rock runs the embedded site as a non-root Pebble service. To load and run it locally:

```shell
skopeo copy oci-archive:$(ls *.rock) docker-daemon:tabor-consulting:local
docker run --rm -p 8080:8080 -p 8081:8081 tabor-consulting:local
```

The website listens on port 8080 and Prometheus metrics on port 8081.
Pull requests build the rock; pushes to `main` publish it to GHCR and deploy to Fly.io.
The deployment requires the `FLY_API_TOKEN` repository secret.

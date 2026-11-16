# tabor-consulting.co.uk

This repository contains the code for https://tabor-consulting.co.uk.
The site is built with [Hugo](https://gohugo.io) and hosted on
[Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/).
Pages, assets and shortlinks are published together, without a server process.

## Development

Install [Canonical Workshop](https://github.com/canonical/workshop) and configure LXD
using the [setup guide](https://documentation.ubuntu.com/canonical-workshop/stable/tutorial/part-1-get-started/),
then run:

```shell
workshop launch
# For an existing environment after pulling SDK changes:
workshop refresh

# Install dependencies, build Hugo, and validate with Wrangler (no credentials):
workshop run -- check

# Hugo development server, exposed on localhost:1313:
workshop run -- dev

# Preview the built site with Cloudflare's local runtime:
workshop run -- preview
```

Workshop supplies Node.js and npm through the official Node SDK on `22/stable`,
plus Hugo extended 0.170.0 and Dart Sass. Wrangler 4.162.0 and its dependencies
are locked in npm. `build` installs dependencies and renders production assets
into `public/`, with the canonical URL `https://tabor-consulting.co.uk` and the
Git commit timestamp as Hugo's build clock. `generate` renders with dependencies
already installed. Actions pass through arguments, for example
`workshop run -- dev --disableFastRender`.

## Publishing

[GitHub Actions](.github/workflows/publish.yaml) publishes only `main` to the
`tabor-consulting` Worker. Set the repository variable `CLOUDFLARE_ACCOUNT_ID` and
secret `CLOUDFLARE_API_TOKEN`. DNS and custom-domain bindings belong to Terraform
in the infrastructure repository, not Wrangler. Pull requests run the same
credential-free `check` action and cannot publish.

To publish locally with both variables exported, use the self-contained action:

```shell
workshop run --env CLOUDFLARE_API_TOKEN --env CLOUDFLARE_ACCOUNT_ID -- deploy
```

It refuses missing credentials before doing any work, installs dependencies,
builds and dry-runs the deployment, then publishes. To exercise that whole action
without publishing, append `--dry-run`:

```shell
workshop run --env CLOUDFLARE_API_TOKEN --env CLOUDFLARE_ACCOUNT_ID -- deploy --dry-run
```

## Redirects and caching

Edit [site/static/_redirects](site/static/_redirects) to maintain shortlinks,
including `/booking` and `/bookings`. Both slash variants are explicit. These
are the Tabor-specific routes formerly loaded from the shared Gist; no runtime
Gist fetch or separate redirect service remains. Redirects take precedence over
assets. Incoming query parameters may carry through to destinations without their
own query. The final rules preserve file URLs with an extra trailing slash.

[site/static/_headers](site/static/_headers) preserves browser-cache policy:
short-lived pages, daily revalidation for stable-name assets, immutable
fingerprinted CSS, and uncached unmatched routes. Cloudflare matches request URLs,
not response status: a missing URL matching an asset rule gets that rule's cache
policy too. Add new extensionless page paths alongside `/pages/consulting/` if
they should use the five-minute page cache rather than the safe `no-store`
default. The sitemap revalidates hourly; feeds and JSON revalidate every request.

Workers Static Assets limits individual files to 25 MiB. `site/static/intro.mp4`
is an H.264/AAC MP4 with fast-start metadata, re-encoded below that limit without
changing its duration, resolution, or audio. Keep replacement videos below the
limit; `check` rejects oversized assets. Local Wrangler currently returns a full
`200` response to video Range requests, so seeking and browser playback at the
Cloudflare edge still need verification during the approved cutover.

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
`.workshop/hugo/scripts/install-dart-sass`. The compiler is pinned to 1.108.1
with archive checksums. Colordrop still uses legacy Sass imports and color
functions, so the base template suppresses import and dependency deprecation
notices until upstream migrates. Project Sass uses modern color functions.
Review the compiler pin and warning options when updating Colordrop.

Workshop uses the upstream Hugo archive via `.workshop/hugo/scripts/install-hugo`
so Hugo can access `/project` and use the separately installed Dart Sass compiler.
The installer smoke-tests the executable directly rather than relying on an
optional `+extended` version-banner suffix. Setup hooks use the SDK bundle via
`$SDK`, because `/project` is not mounted during `setup-base`.

# tabor-consulting.co.uk

[Hugo](https://gohugo.io) site hosted on
[Cloudflare Workers Static Assets](https://developers.cloudflare.com/workers/static-assets/).

## Development

Install [Canonical Workshop](https://github.com/canonical/workshop) and configure LXD
using the [setup guide](https://documentation.ubuntu.com/canonical-workshop/stable/tutorial/part-1-get-started/).

```shell
workshop launch
workshop run -- check
workshop run -- dev
```

The development server is available at http://localhost:1313. Use
`workshop run -- preview` to preview the built site with Cloudflare's local runtime.
Run `workshop refresh` after changing SDK definitions.

Workshop supplies Node.js, Hugo extended and Dart Sass. Wrangler dependencies
are locked in npm. Production assets are generated into `public/`.
Individual static assets must not exceed 25 MiB.

## Publishing

Pushes to `main` publish the `tabor-consulting` Worker. Configure the repository
variable `CLOUDFLARE_ACCOUNT_ID` and secret `CLOUDFLARE_API_TOKEN`.
Pull requests build and validate without publishing.

To build, validate and publish locally with both variables exported:

```shell
workshop run --env CLOUDFLARE_API_TOKEN --env CLOUDFLARE_ACCOUNT_ID -- deploy
```

Append `--dry-run` to validate without publishing. Terraform in
[jnsgruk/infra](https://github.com/jnsgruk/infra) manages DNS and custom-domain bindings.

## Site configuration

- Shortlinks: [site/static/_redirects](site/static/_redirects).
- Browser-cache policies: [site/static/_headers](site/static/_headers).
- Site styles and layouts: `site/assets/sass` and `site/layouts`.
- Custom CSS: `site/static/overrides.css`.

## Theme

Colordrop is vendored at `v2.0.0-alpha.6`, commit
`8820f34752e6e34edf0ff53278d7cdfad3d97dce`, from
[humrochagf/colordrop](https://github.com/humrochagf/colordrop/tree/v2.0.0-alpha.6).
Keep upstream files in `site/themes/colordrop` unchanged; apply site customisations
in the directories above.

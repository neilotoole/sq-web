# sq.io website

[![Netlify Status](https://api.netlify.com/api/v1/badges/7caea069-2a8d-4f0b-bafe-b053bbc5eb08/deploy-status)](https://app.netlify.com/sites/sq-web/deploys)

This is the repo for the [sq.io](https://sq.io) website, which
hosts documentations for [sq](https://github.com/neilotoole/sq).

This site is built using:

- [Hugo](https://gohugo.io) site generator
- [Doks](https://getdoks.org) theme
- [Node.js](https://nodejs.org/) tooling
- [Netlify](https://www.netlify.com) hosting

Changes to the `master` branch kick off a redeploy on Netlify.


## Contributing

You could [open an issue](https://github.com/neilotoole/sq-web/issues), but ideally you'd submit a pull request.


### 1. Clone this repo

```bash
git clone https://github.com/neilotoole/sq-web.git && cd sq-web
```

### 2. Install dependencies

```bash
npm install
```

### 3. Make changes and test locally

```bash
npm run start
```

### 4. Submit a Pull Request

Create a [Pull Request](https://github.com/neilotoole/sq-web/pulls), providing context
for your changes.


## Misc

- Doks comes with [commands](https://getdoks.org/docs/prologue/commands/) for common tasks.
- Use `npm run gen:syntax-css` to regenerate the syntax highlight theme. The themes (light and dark)
  are specified in [generate-syntax-css.sh](./generate-syntax-css.sh).



## Documentation

- [Netlify](https://docs.netlify.com/)
- [Hugo](https://gohugo.io/documentation/)
- [Doks](https://getdoks.org/)

## Communities

- [sq discussions](https://github.com/neilotoole/sq/discussions)
- [Netlify Community](https://community.netlify.com/)
- [Hugo Forums](https://discourse.gohugo.io/)
- [Doks Discussions](https://github.com/h-enk/doks/discussions)

## Acknowledgements

- Special thanks to [Netlify](https://www.netlify.com), who provide
free hosting for [sq.io](https://sq.io) via
their [open source program](https://www.netlify.com/open-source/).
- A bunch of stuff has been lifted from the [Docsy theme](https://www.docsy.dev).

[![Deploys by Netlify](https://www.netlify.com/v3/img/components/netlify-dark.svg)](https://www.netlify.com)


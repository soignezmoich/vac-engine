#!/usr/bin/env node

const postCssPlugin = require('esbuild-plugin-postcss2').default
const path = require('path')

const watch = process.argv.indexOf("watch") >= 0
const css = process.argv.indexOf("css") >= 0
const js = process.argv.indexOf("js") >= 0

let entries = []
if (js) entries.push('js/app.js')
if (css) entries.push('css/app.css')

require('esbuild')
  .build({
    plugins: [
      postCssPlugin({
        plugins: [
          require('postcss-import')({
            path: [
              path.join(__dirname, 'assets/css'),
              path.join(__dirname, 'assets')
            ]
          }),
          require('postcss-url'),
          require('postcss-nested'),
          require('autoprefixer'),
          require('tailwindcss')()
        ]
      })
    ],
    logLevel: 'info',
    entryPoints: entries,
    bundle: true,
    watch: watch,
    minify: process.env.NODE_ENV == "production",
    outdir: '../priv/static/assets/',
    outbase: './',
  })
  .catch(() => process.exit(1))

#!/usr/bin/env node

const postCssPlugin = require('esbuild-style-plugin')
const path = require('path')

const watch = process.argv.indexOf("watch") >= 0
const css = process.argv.indexOf("css") >= 0
const js = process.argv.indexOf("js") >= 0

let entries = []
if (js) entries.push('js/app.js')
if (css) entries.push('css/app.css')

if (watch) {
  process.stdin.on('end', () => process.exit(0))
  process.stdin.resume()
}

require('esbuild')
  .build({
    plugins: [
      postCssPlugin({
        postcss: [
          require('postcss-import')({
            path: [
              path.join(__dirname, 'assets/css'),
              path.join(__dirname, 'assets')
            ]
          }),
          require('postcss-url')({ url: 'inline' }),
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
    sourcemap: process.env.NODE_ENV == "production" ? false : "both",
    outdir: '../priv/static/assets/',
    outbase: './',
  })
  .catch(() => process.exit(1))

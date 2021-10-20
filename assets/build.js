#!/usr/bin/env node

const postCssPlugin = require('esbuild-plugin-postcss2').default
const path = require('path')

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
    entryPoints: ['js/app.js', 'css/app.css'],
    bundle: true,
    watch: process.argv.indexOf("watch") >= 0,
    minify: process.env.NODE_ENV == "production",
    outdir: '../priv/static/assets/'
  })
  .catch(() => process.exit(1))

const path = require('path')
const glob = require('glob')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const FileManagerPlugin = require('filemanager-webpack-plugin')
const WebpackWatchPlugin = require('webpack-watch-files-plugin').default

module.exports = (env, options) => ({
  entry: {
    './js/app.js': ['./js/app.js'].concat(glob.sync('./vendor/**/*.js'))
  },
  output: {
    filename: 'app.js',
    path: path.resolve(__dirname, '../priv/static/js')
  },
  module: {
    rules: [{
      test: /\.js$/,
      exclude: /node_modules/,
      use: {
        loader: 'babel-loader'
      }
    },
    {
      test: /\.css$/,
      exclude: /node_modules/,
      use: [
        MiniCssExtractPlugin.loader,
        {
          loader: 'css-loader',
          options: {
            importLoaders: 1,
            url: false
          }
        },
        {
          loader: 'postcss-loader'
        }]
    }]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: '../css/app.css'
    }),
    new FileManagerPlugin({
      events: {
        onEnd: {
          copy: [{
            source: 'static/',
            destination: '../priv/static/'
          }]
        }
      }
    }),
    new WebpackWatchPlugin({
      files: [
        'static/**/*'
      ]
    })
  ]
})

const extract = (content) => {
  return content.match(/[A-z0-9-:\/@]+/g) || []
}

module.exports = {
  extractors: [
    {
      extractor: extract,
      extensions: ['eex', 'leex']
    }
  ],
  content: [
    '../lib/**/*.leex',
    '../lib/**/*.eex'
  ],
  safelist: { greedy: [/phx-/] },
  css: ['../priv/static/css/app.css']
}

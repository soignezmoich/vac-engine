const extract = (content) => {
  return content.match(/[A-z0-9-:.\/@]+/g) || []
}

module.exports = {
  extractors: [
    {
      extractor: extract,
      extensions: ['ex', 'heex', 'eex', 'leex']
    }
  ],
  content: [
    '../lib/**/*.ex',
    '../lib/**/*.leex',
    '../lib/**/*.heex',
    '../lib/**/*.eex'
  ],
  safelist: { greedy: [/phx-/] },
  css: ['../priv/static/assets/css/app.css']
}

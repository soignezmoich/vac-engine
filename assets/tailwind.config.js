const hsluv = require('hsluv')

function hsluvaToRgba (h, s, l, a) {
  if (a === undefined) {
    a = 1
  }
  const rgb = hsluv.hsluvToRgb([h, s, l])
  return 'rgba(' +
    (Math.round(255 * rgb[0])) + ', ' +
    (Math.round(255 * rgb[1])) + ', ' +
    (Math.round(255 * rgb[2])) + ', ' +
    a + ')'
}



function genCreams () {
  const res = {}
  for (let i = 1; i < 20; i++) {
    res[50 * i] = hsluv.hsluvToHex([60, 20, 100 - 5 * i])
  }
  return res
}

module.exports = {
  purge: false,
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true
  },
  theme: {
    extend: {
      colors: {
        cream: genCreams(),
      },
      outline: {
        cream: '2px solid ' + hsluvaToRgba(60, 20, 50, 1)
      },
      spacing: {
        72: '18rem',
        84: '21rem',
        96: '24rem'
      },
      width: {
        128: '32rem',
        192: '48rem'
      }
    }
  },
  variants: {
    textColor: ['responsive', 'hover', 'focus', 'disabled']
  }
}

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



function genBlues () {
  const res = {}
  for (let i = 1; i < 50; i++) {
    res[20 * i] = hsluv.hsluvToHex([174, 20, 100 - 2 * i])
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
        blue: genBlues(),
      },
      outline: {
        blue: '2px solid ' + hsluvaToRgba(174, 90, 50, 1)
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

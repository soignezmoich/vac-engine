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


function genShades (h, s) {
  const res = {}
  for (let i = 1; i < 20; i++) {
    res[50 * i] = hsluv.hsluvToHex([h, s, 102 - 5 * i])
  }
  return res
}

module.exports = {
  content: [
     '../lib/**/*.{heex,ex,exs}',
     './js/**/*.{html,js}',
     './css/**/*.{html,js}',
   ],
  theme: {
    extend: {
      colors: {
        cream: genShades(60, 20),
        gray: genShades(60, 5),
        red: genShades(0, 70),
        error: genShades(0, 50),
        blue: genShades(255, 50)
      },
      spacing: {
        72: '18rem',
        84: '21rem',
        96: '24rem'
      },
      width: {
        128: '32rem',
        192: '48rem',
        256: '64rem',
      },
      maxWidth: {
       '2xs': '10rem'
      }
    }
  }
}

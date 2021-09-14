import css from '../css/app.css'
import {
  Socket
} from 'phoenix'
import {
  LiveSocket
} from 'phoenix_live_view'

const removeDiacritics = require('diacritics').remove

const Hooks = {}

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
const liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  dom: {
    onBeforeElUpdated (from, to) {
      for (let i in window.DROPDOWNS) {
        window.DROPDOWNS[i].close()
      }
    }
  },
  hooks: Hooks
})

liveSocket.connect()
window.liveSocket = liveSocket

function sluggize (str) {
  return removeDiacritics(str).replace(/\s/g, '_').toLowerCase().replace(/\W/g, '_')
}

Hooks.focus = {
  mounted () {

  },
  updated () {
    const el = document.getElementById(this.el.dataset.focus)
    el.focus()
  }
}

Hooks.sluggize = {
  mounted () {
    this.el.addEventListener("keyup", (evt) => this.sluggize())
    this.el.addEventListener("change", (evt) => this.sluggize())
  },
  sluggize () {
    this.el.value = sluggize(this.el.value)
  }
}


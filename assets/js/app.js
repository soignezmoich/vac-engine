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
      for (const i in window.DROPDOWNS) {
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
    this.el.addEventListener('keyup', (evt) => this.sluggize())
    this.el.addEventListener('change', (evt) => this.sluggize())
  },
  sluggize () {
    this.el.value = sluggize(this.el.value)
  }
}

Hooks.clipboardCopy = {
  mounted () {
    this.el.addEventListener('click', (evt) => this.copy(evt))
  },
  copy (evt) {
    const text = this.el.innerHTML.trim()
    const r = this.el.getBoundingClientRect()
    this.el.style.width = r.width + "px"
    navigator.clipboard.writeText(text).then(() => {
      this.el.innerHTML = "copied!"
      setTimeout(() => this.el.innerHTML = text, 1500)
    })
  }
}

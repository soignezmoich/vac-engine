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
    this.el.style.width = r.width + 'px'
    navigator.clipboard.writeText(text).then(() => {
      this.el.innerHTML = 'copied!'
      setTimeout(() => this.el.innerHTML = text, 1500)
    })
  }
}

function get_classes (el) {
  const classes = el
    .getAttribute("class")
    .split(/\s/)
    .map((c) => c.trim())
    .filter((c) => c.length > 0)

  return classes
}

function removeClass (el, name) {
  const classes = get_classes(el)
    .filter((c) => c != name)
    .join(" ")

  el.setAttribute("class", classes)
}

function addClass (el, name) {
  const classes = get_classes(el)
    .filter((c) => c != name)
    .concat([name])
    .join(" ")

  el.setAttribute("class", classes)
}

function closeListener (evt) {
  let current = evt.target
  if (!current) return
  while (current && current != document.body) {
    if (current.dataset.dropdown && current.dataset.open) return
    current = current.parentElement
  }
  const els = document.querySelectorAll("[data-dropdown][data-open]")
  for (let el of els) {
    closeDropdown(el)
  }
}

function closeDropdown(el) {
  const target = document.getElementById(el.dataset.dropdown)

  removeClass(el, "bg-blue-600")
  removeClass(el, "text-gray-100")
  addClass(target, "hidden")
  delete el.dataset.open
}

function openDropdown(el) {
  const target = document.getElementById(el.dataset.dropdown)

  addClass(el, "bg-blue-600")
  addClass(el, "text-gray-100")
  removeClass(target, "hidden")
  el.dataset.open = true
}

function installDropdowns () {
  const els = document.querySelectorAll("[data-dropdown]")

  for (let el of els) {
    if (el.__dropdown) continue
    el.addEventListener("click", () => openDropdown(el))
    el.__dropdown = true
  }
  if (document.__dropdown) return
  document.addEventListener("click", closeListener)
  document.__dropdown = true
}

window.addEventListener('load', installDropdowns)
window.addEventListener("phx:page-loading-stop", installDropdowns)

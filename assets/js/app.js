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

Hooks.focusOnMount = {
  mounted () {
    this.el.focus()
  },
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
    const text = this.el.__text || this.el.innerText.trim()
    this.el.__text = text
    const r = this.el.getBoundingClientRect()
    this.el.style.width = r.width + 'px'
    navigator.clipboard.writeText(text).then(() => {
      this.el.innerHTML = 'copied!'
      setTimeout(() => this.el.innerHTML = text, 1500)
    })
  }
}

Hooks.confirmClick = {
  mounted () {
    this.confirmVisible = false
    this.el.addEventListener("click", (evt) => {
      if (!this.el.dataset.confirmVisible) {
        this.showConfirm()
        evt.stopPropagation()
        addTimeout("confirm", 3000, () => {
          this.hideConfirms()
        })
      } else {
        this.hideConfirms()
      }
    })
  },
  updated () {
  },
  showConfirm () {
    this.hideConfirms()
    for (let el of this.el.querySelectorAll("[data-confirm]")) {
      removeClass(el, "hidden")
    }
    this.el.dataset.confirmVisible = true
  },
  hideConfirms () {
    removeTimeout("confirm")
    for (let el of document.querySelectorAll("[data-confirm]")) {
      addClass(el, "hidden")
      delete el.parentElement.dataset.confirmVisible
    }
  }
}

Hooks.action = {
  mounted () {
    this.actionFns = {
      scroll_to: this.scrollTo
    }
    this.handleEvent("action", (data) => {
      if (data.id == this.el.id) {
        this.doAction(data.action, data.params)
      }
    })
  },
  doAction (action, params) {
    let actionFn = this.actionFns[action]
    if (actionFn) {
      actionFn.apply(this, params)
    }
  },
  scrollTo (target) {
    let targetEl = document.getElementById(target)
    let targetRect = targetEl.getBoundingClientRect()
    let rect = this.el.getBoundingClientRect()
    let offset =  targetRect.top -  rect.top
    console.log(targetRect)
    console.log(rect)
    console.log(offset)

    if (offset < 0 || offset > rect.height) {
      this.el.scrollTo({top: this.el.scrollTop + offset, behavior: "smooth"})
    }
  }
}

const TIMEOUTS = {}

function addTimeout (name, delay, fun) {
  if (TIMEOUTS[name]) {
    clearTimeout(TIMEOUTS[name])
  }
  let timeout = setTimeout(() => {
    delete TIMEOUTS[name]
    fun()
  }, delay)
  TIMEOUTS[name] = timeout
}

function removeTimeout (name, delay, fun) {
  if (TIMEOUTS[name]) {
    clearTimeout(TIMEOUTS[name])
  }
  delete TIMEOUTS[name]
}

function getClasses (el) {
  const classes = el
    .getAttribute("class")
    .split(/\s/)
    .map((c) => c.trim())
    .filter((c) => c.length > 0)

  return classes
}

function hasClass (el, name) {
  return getClasses(el).indexOf(name) >= 0
}

function removeClass (el, name) {
  const classes = getClasses(el)
    .filter((c) => c != name)
    .join(" ")

  el.setAttribute("class", classes)
}

function addClass (el, name) {
  if (hasClass(el, name)) {
    return
  }

  const classes = getClasses(el)
    .filter((c) => c != name)
    .concat([name])
    .join(" ")

  el.setAttribute("class", classes)
}

function closeListener (evt) {
  let current = evt.target

  while (current && current != document.body) {
    if (current.dataset.dropdown && current.id == document.__currentDropdown) {
      return
    }
    current = current.parentElement
  }
  const els = document.querySelectorAll("[data-dropdown]")
  for (let el of els) {
    closeDropdown(el)
  }
}

function closeDropdown(el) {
  const target = document.getElementById(el.dataset.dropdown)

  addClass(target, "hidden")
  document.__currentDropdown = null
}

function openDropdown(el, force) {
  const other = document.getElementById(document.__currentDropdown)
  if (other) {
    closeDropdown(other)
  }
  if (!other && ! force) return

  const target = document.getElementById(el.dataset.dropdown)

  removeClass(target, "hidden")
  document.__currentDropdown = el.id
}

function installDropdowns () {
  const els = document.querySelectorAll("[data-dropdown]")

  for (let el of els) {
    if (el.__dropdown) continue
    el.addEventListener("click", () => openDropdown(el, true))
    el.addEventListener("mouseover", () => openDropdown(el, false))
    el.__dropdown = true
  }
  if (document.__dropdown) return
  document.addEventListener("click", closeListener)
  document.__dropdown = true
}

window.addEventListener('load', installDropdowns)
window.addEventListener("phx:page-loading-stop", installDropdowns)



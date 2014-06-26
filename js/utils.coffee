addClass = (el, className) ->
  if hasClass el, className then return
  if el.classList
    el.classList.add className
  else
    el.className += ' ' + className
  return

removeClass = (el, className) ->
  if el.classList
    el.classList.remove className
  else
    el.className = el.className.replace(new RegExp("(^|\\b)" + className.split(" ").join("|") + "(\\b|$)", "gi"), " ")
  return

hasClass = (el, className) ->
  if el.classList
    return el.classList.contains className
  else
    return new RegExp("(^| )" + className + "( |$)", "gi").test el.className

toggleClass = (el, className) ->
  if hasClass el, className
    removeClass el, className
  else
    addClass el, className

getEl = (id) ->
  document.getElementById id

transitionEndEvent = () ->
  el = document.createElement('div')
  transEndEventNames =
    WebkitTransition: 'webkitTransitionEnd'
    MozTransition: 'transitionend'
    transition: 'transitionend'
  for name of transEndEventNames
    return transEndEventNames[name] if el.style[name] isnt undefined
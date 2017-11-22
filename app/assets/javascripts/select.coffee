$(document).on 'click', '#display-link', (event) ->
  event.preventDefault()
  location = document.getElementById("restaurants")
  up = document.getElementById("up-link")
  style = location.style.flexWrap
  if style == 'nowrap'
    location.style.flexWrap = 'wrap'
    location.style.justifyContent = 'center'
    location.style.overflowX = ''
    up.style.visibility = "visible"
    window.scroll_to_card(location.style.flexWrap)
  else
    location.style.flexWrap = 'nowrap'
    location.style.justifyContent = 'flex-start'
    location.style.overflowX = 'auto'
    up.style.visibility = "hidden"
    window.scroll_to_card(location.style.flexWrap)
  return

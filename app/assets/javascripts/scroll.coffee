$(document).on 'click', '#up-link', (event) ->
  event.preventDefault()
  $('html, body').animate { scrollTop: 0 }, 'slow'
  false

$(document).on 'click', '#clearbutton', (event) ->
  event.preventDefault()
  document.getElementById('searchbox').value = ''
  return

window.scroll_to_card = (style) ->
  if style == 'wrap'
    $('#restaurants').animate { scrollTop: $('#restaurant_1').position().top }, 'slow'
  else
    $('#restaurants').animate { scrollLeft: $('#restaurant_1').position().left }, 'slow'
  return

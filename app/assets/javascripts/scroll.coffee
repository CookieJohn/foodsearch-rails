$(document).on 'click', '#map-link', (event) ->
  event.preventDefault()
  $('html, body').animate { scrollTop: 0 }, 'slow'
  false

$(document).on 'click', '#search-link', (event) ->
  event.preventDefault()
  $('#search-form').slideToggle()

$(document).on 'click', '#clearbutton', (event) ->
  event.preventDefault()
  document.getElementById('searchbox').value = ''

window.search_bar_toggle = (state=false) ->
  $('#search-form').toggle(state)
  return

window.scroll_to_card = () ->
  display_cookie = document.cookie.indexOf('display=')
  if display_cookie == -1
          $('html, body').animate { scrollTop: $('#google_address').position().top }, 'slow'
  else
    match = document.cookie.match(new RegExp('display=([^;]+)'))
    cookie = match[0].split('=')
    window.search_bar_toggle()
    if cookie[1] == 'wrap'
      $('html, body').animate { scrollTop: $('#google_address').position().top }, 'slow'
    else
      $('html, body').animate { scrollTop: $('#restaurants').position().top }, 'slow'
      element =  document.getElementById('restaurant_1');
      if typeof element != 'undefined' && element != null
        $('#restaurants').animate { scrollLeft: $('#restaurant_1').position().left }, 'slow'
    return

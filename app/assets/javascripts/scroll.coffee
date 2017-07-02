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
		$('html, body').animate { scrollTop: $('#results_num').position().top }, 'slow'
	else
	  match = document.cookie.match(new RegExp('display=([^;]+)'))
	  cookie = match[0].split('=')
	  window.search_bar_toggle()
	  window.scroll_to_card
	  if cookie[1] == 'wrap'
	    $('html, body').animate { scrollTop: $('#google_address').position().top }, 'slow'
	  else
	    $('html, body').animate { scrollTop: $('#locations').position().top }, 'slow'
	    element =  document.getElementById('location_1');
	    if typeof element != 'undefined' && element != null
	      $('#locations').animate { scrollLeft: $('#location_1').position().left }, 'slow'
	  return
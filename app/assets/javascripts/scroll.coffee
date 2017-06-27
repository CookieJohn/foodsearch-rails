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
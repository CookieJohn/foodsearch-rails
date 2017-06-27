$(document).on 'click', '#map-link', (event) ->
  event.preventDefault()
  $('html, body').animate { scrollTop: 0 }, 'slow'
  false

$(document).on 'click', '#search-link', (event) ->
	event.preventDefault()
	window.search_bar_toggle()

window.search_bar_toggle = () ->
  $('#search-form').slideToggle()
  return
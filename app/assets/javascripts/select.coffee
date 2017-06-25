$(document).on 'change', '#sort-mode', (event) ->
  lat = window.current_lat
  lng = window.current_lng
  document.cookie = 'mode=' + this.value
  if typeof lat != 'undefined' and typeof lng != 'undefined'
    window.send_post(lat, lng)
  return

$(document).on 'change', '#display-mode', (event) ->  
  document.cookie = 'display=' + this.value
  set_display(this.value)
  # $('html, body').animate { scrollTop: $('#locations').position().top }, 'slow'

$ ->
	match = document.cookie.match(new RegExp('display=([^;]+)'));
	cookie = match[0].split('=')
	set_display(cookie[1])

window.set_display = (value) ->
	location = document.getElementById("locations")
	if value == 'wrap'
		location.style.flexWrap = 'wrap'
		location.style.justifyContent = 'center'
		location.style.overflowX = ''
		$('html, body').animate { scrollTop: $('#results_num').position().top }, 'slow'
	else
		location.style.flexWrap = 'nowrap'
		location.style.justifyContent = 'flex-start'
		location.style.overflowX = 'auto'
		$('html, body').animate { scrollTop: $('#locations').position().top }, 'slow'
	return

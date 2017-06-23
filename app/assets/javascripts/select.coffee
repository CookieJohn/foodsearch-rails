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

$ ->
	match = document.cookie.match(new RegExp('display=([^;]+)'));
	cookie = match[0].split('=')
	set_display(cookie[1])

window.set_display = (value) ->
	location = document.getElementById("locations")
	if value == 'wrap'
		location.style.flexWrap = 'wrap'
		location.style.justifyContent = 'center'
	else
		location.style.flexWrap = 'nowrap'
		location.style.justifyContent = 'flex-start'
	return

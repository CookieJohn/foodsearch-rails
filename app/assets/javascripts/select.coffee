$(document).on 'change', '#sort-mode', (event) ->
  lat = window.current_lat
  lng = window.current_lng
  document.cookie = 'mode=' + this.value
  if typeof lat != 'undefined' and typeof lng != 'undefined'
    window.send_post(lat, lng)
  return

$(document).on 'change', '#display-mode', (event) ->  
  document.cookie = 'display=' + this.value
  if this.value == 'wrap'
    document.getElementById("locations").style.flexWrap = this.value;
    document.getElementById("locations").style.justifyContent = 'center'
  else
    document.getElementById("locations").style.flexWrap = this.value;
    document.getElementById("locations").style.justifyContent = 'flex-start'
  return

$ ->
	match = document.cookie.match(new RegExp('display=([^;]+)'));
	cookie = match[0].split('=')
	if cookie[1] == 'wrap'
		document.getElementById("locations").style.flexWrap = 'wrap'
		document.getElementById("locations").style.justifyContent = 'center'
	else
		document.getElementById("locations").style.flexWrap = 'nowrap'
		document.getElementById("locations").style.justifyContent = 'flex-start'
	return
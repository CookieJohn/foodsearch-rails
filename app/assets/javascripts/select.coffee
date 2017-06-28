$(document).on 'change', '#sort-mode', (event) ->
  lat = window.current_lat
  lng = window.current_lng
  document.cookie = 'mode=' + this.value
  if typeof lat != 'undefined' and typeof lng != 'undefined'
    window.send_post(lat, lng)
  return

$(document).on 'change', '#display-mode', (event) ->  
  mode = this.value
  document.cookie = 'display=' + mode
  window.set_display()

$(document).on 'change', '#type-mode', (event) ->  
  lat = window.current_lat
  lng = window.current_lng
  type = this.value
  document.cookie = 'type=' + type
  if typeof lat != 'undefined' and typeof lng != 'undefined'
    window.send_post(lat, lng)
  return

window.set_display = (value) ->
  match = document.cookie.match(new RegExp('display=([^;]+)'));
  cookie = match[0].split('=')
  location = document.getElementById("locations")
  if cookie[1] == 'wrap'
    location.style.flexWrap = 'wrap'
    location.style.justifyContent = 'center'
    location.style.overflowX = ''
    $('html, body').animate { scrollTop: $('#results_num').position().top }, 'slow'
  else
    location.style.flexWrap = 'nowrap'
    location.style.justifyContent = 'flex-start'
    location.style.overflowX = 'auto'
    $('html, body').animate { scrollTop: $('#locations').position().top }, 'slow'
    element =  document.getElementById('location_1');
    if typeof element != 'undefined' && element != null
      $('#locations').animate { scrollLeft: $('#location_1').position().left }, 'slow'
  return

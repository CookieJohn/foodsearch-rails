$(document).on 'change', '#sort-mode', (event) ->
  lat = window.current_lat
  lng = window.current_lng
  document.cookie = 'mode=' + this.value
  if typeof lat != 'undefined' and typeof lng != 'undefined'
    window.send_post(lat, lng)
  return
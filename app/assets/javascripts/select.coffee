$(document).on 'change', '#sort-mode', (event) ->
  document.cookie = 'mode=' + this.value
  if typeof current_lat != 'undefined' and typeof current_lng != 'undefined'
    send_post(current_lat, current_lng)
  return
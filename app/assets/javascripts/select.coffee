$(document).on 'change', '#select-mode', (event) ->
  s = document.getElementById('select-mode')
  value = s[s.selectedIndex].value
  document.cookie = 'mode=' + value
  if typeof current_lat != 'undefined' and typeof current_lng != 'undefined'
    send_post current_lat, current_lng
  return
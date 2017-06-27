$(document).on 'click', '#searchsubmit', (event) ->  
  event.preventDefault()
  lat = window.current_lat
  lng = window.current_lng
  if typeof lat != 'undefined' and typeof lng != 'undefined'
    window.send_post(lat, lng)
  return
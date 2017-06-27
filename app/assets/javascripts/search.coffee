$(document).on 'click', '#searchsubmit', (event) ->  
  event.preventDefault()
  lat = window.current_lat
  lng = window.current_lng
  search_type = document.getElementById('searchbox').value
  if typeof lat != 'undefined' and typeof lng != 'undefined'
    window.send_post(lat, lng, search_type)
  return
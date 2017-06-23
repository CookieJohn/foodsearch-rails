$ ->
  window.detect_position = (map, marker, uluru) ->
    infoWindow = ''
    $('#loading').show()
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition ((position) ->
        lat = position.coords.latitude
        lng = position.coords.longitude
        window.current_lat = lat
        window.current_lng = lng
        pos = 
          lat: lat
          lng: lng
        marker.setPosition pos
        map.setCenter pos
        $('#loading').hide()
        window.send_post(lat, lng)
        return
      ), ->
        handleLocationError true, infoWindow, map.getCenter(), map, marker, uluru
        return
    else
      handleLocationError false, infoWindow, map.getCenter(), map, marker, uluru
    return

  window.handleLocationError = (browserHasGeolocation, infoWindow, pos, map, marker, uluru) ->
    marker.setPosition uluru
    map.setCenter uluru
    $('#loading').hide()
    return
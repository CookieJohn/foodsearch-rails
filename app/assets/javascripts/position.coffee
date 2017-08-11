$ ->
  window.detect_position = (map, marker, uluru, cityCircle) ->
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
        window.move_circle(cityCircle, {lat: lat,lng: lng})
        $('#loading').hide()
        window.send_post(lat, lng)
        return
      ), ->
        handleLocationError true, infoWindow, map.getCenter(), map, marker, uluru
        if rails_env != 'development'
          setTimeout(location_open_notification, 500);
        return
    else
      handleLocationError false, infoWindow, map.getCenter(), map, marker, uluru
    return

  window.handleLocationError = (browserHasGeolocation, infoWindow, pos, map, marker, uluru) ->
    marker.setPosition uluru
    map.setCenter uluru
    $('#loading').hide()
    return

  location_open_notification = () ->
    alert('您未開啟裝置的位置功能\n您可以在開啟位置功能後\n重新整理頁面')
    return
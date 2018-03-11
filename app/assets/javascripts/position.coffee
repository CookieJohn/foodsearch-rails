class window.Position
  detect_position: (show_loading = true) ->
    google_map = new GoogleMap
    # infoWindow = ''
    # $('#loading').show()
    if navigator.geolocation
      $('#loading').show() if show_loading
      navigator.geolocation.getCurrentPosition ((position) ->
        lat = position.coords.latitude
        lng = position.coords.longitude
        center =
          lat: lat
          lng: lng
        window.marker.setPosition center
        window.map.setCenter center
        google_map.move_circle(center)
        google_map.set_current_lat_lng(lat, lng)
        $('#loading').hide()
        # window.send_post(lat, lng)
        return
      ), ->
        # handleLocationError true, infoWindow, map.getCenter(), map, marker, uluru
        # today = new Date()
        # dd = today.getDate()
        # if rails_env != 'development' && !document.cookie.match(new RegExp("notice_date=#{dd}"))
        #   setTimeout(location_open_notification, 800)
        $('#loading').hide()
        alert('定位失敗\n請開啟位置功能後\n重新整理頁面') if show_loading
        return
    else
      $('#loading').hide()
      alert('定位失敗\n請開啟位置功能後\n重新整理頁面') if show_loading
      # handleLocationError false, infoWindow, map.getCenter(), map, marker, uluru
    return

#   window.handleLocationError = (browserHasGeolocation, infoWindow, pos, map, marker, uluru) ->
#     marker.setPosition uluru
#     map.setCenter uluru
#     $('#loading').hide()
#     return

#   location_open_notification = () ->
#     today = new Date()
#     dd = today.getDate()
#     document.cookie = 'notice_date=' + dd
#     alert('您未開啟裝置的位置功能\n您可以在開啟位置功能後\n重新整理頁面')
#     return

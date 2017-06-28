window.current_lat = 25.059651
window.current_lng = 121.533380

window.default_lat = 25.059651
window.default_lng = 121.533380

$ ->
  window.initMap = ->
    lat = window.default_lat
    lng = window.default_lng
    uluru = 
      lat: lat
      lng: lng
    map = new (google.maps.Map)(document.getElementById('map'), zoom: 14)
    marker = new (google.maps.Marker)(
      map: map
      draggable: true)
    window.detect_position(map, marker, uluru)
    geocoder = new (google.maps.Geocoder)
    loading = document.getElementById('loading')
    google.maps.event.addListener marker, 'dragend', (event) ->
      lat = event.latLng.lat()
      lng = event.latLng.lng()
      window.current_lat = lat
      window.current_lng = lng
      map.setCenter new (google.maps.LatLng)(lat, lng)
      window.send_post(current_lat, current_lng)
      geocoder.geocode { 'latLng': event.latLng }, (results, status) ->
        if status == google.maps.GeocoderStatus.OK
          if results[0]
            document.getElementById('google_address').innerHTML = results[0].formatted_address
        return
      return
    window.set_display()
    if rails_env == 'development'
      window.send_post(window.default_lat, window.default_lng)
    return
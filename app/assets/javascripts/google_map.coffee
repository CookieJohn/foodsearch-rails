# https://developers.google.com/maps/documentation/javascript/examples/places-searchbox?hl=zh-tw
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
    myStyle = [
      {
        featureType: 'poi'
        elementType: 'labels'
        stylers: [ { visibility: 'off' } ]
      }
    ]
    map = new (google.maps.Map)(
      document.getElementById('map'), 
      zoom: 15,
      styles: myStyle,
      streetViewControl: false, #小黃人
      fullscreenControl: false,
      mapTypeControl: false, 
    )
    marker = new (google.maps.Marker)(
      map: map
      draggable: true)

    input = document.getElementById('pac-input')
    searchBox = new (google.maps.places.SearchBox)(input)
    map.controls[google.maps.ControlPosition.TOP_CENTER].push input
    # Bias the SearchBox results towards current map's viewport.

    map.addListener 'bounds_changed', ->
      searchBox.setBounds map.getBounds()
      return
    markers = []

    cityCircle = window.set_circle(map, {lat: lat, lng: lng})
    window.detect_position(map, marker, uluru, cityCircle)
    geocoder = new (google.maps.Geocoder)
    loading = document.getElementById('loading')
    google.maps.event.addListener marker, 'dragend', (event) ->
      lat = event.latLng.lat()
      lng = event.latLng.lng()
      window.current_lat = lat
      window.current_lng = lng
      map.setCenter new (google.maps.LatLng)(lat, lng)
      window.move_circle(cityCircle, {lat: lat,lng: lng})
      window.send_post(lat, lng)
      geocoder.geocode { 'latLng': event.latLng }, (results, status) ->
        # if status == google.maps.GeocoderStatus.OK
        #   if results[0]
        #     document.getElementById('google_address').innerHTML = results[0].formatted_address
        # return
      return
    
    searchBox.addListener 'places_changed', ->
      places = searchBox.getPlaces()
      if places.length == 0
        return
      places.forEach (place) ->
        location = place.geometry.location
        lat = location.lat()
        lng = location.lng()
        window.current_lat = lat
        window.current_lng = lng
        map.setCenter new (google.maps.LatLng)(lat, lng)
        window.move_circle(cityCircle, {lat: lat,lng: lng})
        marker.setPosition(location)
        map.zoom = 15
        window.send_post(lat, lng)
      return

    window.set_display()
    # if rails_env == 'development'
    #   window.send_post(window.default_lat, window.default_lng)
    # return
  # set circle around maker
  window.set_circle = (map, center) ->
    circle_options = {
      strokeColor: '#FF0000',
      strokeOpacity: 0.5,
      strokeWeight: 2,
      fillColor: '#FF0000',
      fillOpacity: 0.05,
      map: map,
      center: center,
      radius: 500,
      # draggable:true
    }
    cityCircle = new google.maps.Circle(circle_options)
    return cityCircle
  window.move_circle = (cityCircle, center) ->
    cityCircle.setOptions({center: center})

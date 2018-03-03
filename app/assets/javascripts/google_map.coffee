# https://developers.google.com/maps/documentation/javascript/examples/places-searchbox?hl=zh-tw
myStyle = [
  {
    featureType: 'poi'
    elementType: 'labels'
    stylers: [ { visibility: 'off' } ]
  }
]
mapStyle = {
  zoom: '',
  styles: myStyle,
  streetViewControl: false, #小黃人
  fullscreenControl: false,
  mapTypeControl: false,
  center: ''
}

$ ->
  window.current_lat   = 25.059651
  window.current_lng   = 121.533380
  window.remove_height = 103
  position = new Position
  google_map = new GoogleMap

  window.initMap = ->
    lat = window.current_lat
    lng = window.current_lng
    document.getElementById("current_lat").value = lat
    document.getElementById("current_lng").value = lng

    center =
      lat: lat
      lng: lng

    mapStyle.zoom = parseInt(document.getElementById("zoom").value, 10)
    mapStyle.center = center
    map = new (google.maps.Map)(document.getElementById('map'), mapStyle)
    marker = new (google.maps.Marker)(
      map: map,
      position: center,
      draggable: true)

    google_map.resize_map(google, map)

    cityCircle = google_map.set_circle(map, {lat: lat, lng: lng})
    position.detect_position(map, marker, center, cityCircle)
    google_map.set_current_lat_lng

    google.maps.event.addListener marker, 'dragend', (event) ->
      lat = event.latLng.lat()
      lng = event.latLng.lng()

      google_map.update_position(lat, lng)
      google_map.set_current_lat_lng
      map.setCenter new (google.maps.LatLng)(lat, lng)
      google_map.move_circle(cityCircle, {lat: lat,lng: lng})
      # geocoder = new (google.maps.Geocoder)
      # window.send_post(lat, lng)
      # geocoder.geocode { 'latLng': event.latLng }, (results, status) ->
        # if status == google.maps.GeocoderStatus.OK
        #   if results[0]
        #     document.getElementById('google_address').innerHTML = results[0].formatted_address
        # return
      return

    input = document.getElementById('pac-input')
    clear = document.getElementById('clear-search')
    map.controls[google.maps.ControlPosition.TOP_CENTER].push input
    map.controls[google.maps.ControlPosition.TOP_CENTER].push clear
    input.style.display = "inline"
    clear.style.display = "inline"
    searchBox = new (google.maps.places.SearchBox)(input)

    searchBox.addListener 'places_changed', ->
      places = searchBox.getPlaces()
      if places.length == 0
        return
      places.forEach (place) ->
        location = place.geometry.location
        lat = location.lat()
        lng = location.lng()
        update_position(lat, lng)
        google_map.set_current_lat_lng

        setTimeout ->
          map.setCenter new (google.maps.LatLng)(lat, lng)
          google_map.move_circle(cityCircle, {lat: lat,lng: lng})
          marker.setPosition(location)
        , 100
      return

class window.GoogleMap
  # set circle around maker
  set_circle: (map, center) ->
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
  move_circle: (cityCircle, center) ->
    cityCircle.setOptions({center: center})
    return

  update_position: (lat, lng) ->
    window.current_lat = lat
    window.current_lng = lng
    return

  resize_map: (google = window.google, map) ->
    new_height = (window.innerHeight - window.remove_height)
    $('#map').css({'width':'100%','height':"#{new_height}"})
    google.maps.event.trigger(map, 'resize')
    return

  set_current_lat_lng: ->
    document.getElementById("current_lat").value = lat
    document.getElementById("current_lng").value = lng
    return

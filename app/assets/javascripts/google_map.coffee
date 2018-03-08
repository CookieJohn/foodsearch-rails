# https://developers.google.com/maps/documentation/javascript/examples/places-searchbox?hl=zh-tw
myStyle = [
  {
    featureType: 'poi'
    elementType: 'labels'
    stylers:     [ { visibility: 'off' } ]
  }
]
mapStyle = {
  zoom:              '',
  styles:            myStyle,
  streetViewControl: false, #小黃人
  fullscreenControl: false,
  mapTypeControl:    false,
  center:            ''
}

$ ->
  window.current_lat   = 25.059651
  window.current_lng   = 121.533380
  window.remove_height = 103
  position             = new Position()
  google_map           = new GoogleMap()

  window.initMap = ->
    lat = window.current_lat
    lng = window.current_lng

    center =
      lat: lat
      lng: lng

    mapStyle.zoom   = parseInt(document.getElementById("zoom").value, 10)
    mapStyle.center = center
    map             = new (google.maps.Map)(document.getElementById('map'), mapStyle)
    marker = new (google.maps.Marker)(
      map:       map,
      position:  center,
      draggable: true
    )

    cityCircle = google_map.set_circle(map, {lat: lat, lng: lng})
    position.detect_position(map, marker, center, cityCircle)
    google_map.set_current_lat_lng(lat, lng)

    google_map.resize_map(google, map)

    search_input = google_map.set_items_in_map(map)
    searchBox    = new (google.maps.places.SearchBox)(search_input)

    # drag event
    google.maps.event.addListener marker, 'dragend', (event) ->
      lat = event.latLng.lat()
      lng = event.latLng.lng()

      google_map.update_position(lat, lng)
      google_map.set_current_lat_lng(lat, lng)
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

    # search address event
    searchBox.addListener 'places_changed', ->
      places = searchBox.getPlaces()
      if places.length == 0
        return
      places.forEach (place) ->
        location = place.geometry.location
        lat = location.lat()
        lng = location.lng()
        google_map.update_position(lat, lng)
        google_map.set_current_lat_lng(lat, lng)

        setTimeout ->
          map.setCenter new (google.maps.LatLng)(lat, lng)
          google_map.move_circle(cityCircle, {lat: lat,lng: lng})
          marker.setPosition(location)
        , 100
      return

class window.GoogleMap
  set_items_in_map: (map, google = window.google) ->
    search_input = document.getElementById('pac-input')
    clear_button = document.getElementById('clear-search')
    map.controls[google.maps.ControlPosition.TOP_CENTER].push search_input
    map.controls[google.maps.ControlPosition.TOP_CENTER].push clear_button
    search_input.style.display = "inline"
    clear_button.style.display = "inline"
    return search_input

  set_circle: (map, center) ->
    circle_options   = {
      strokeColor:   '#FF0000',
      strokeOpacity: 0.5,
      strokeWeight:  2,
      fillColor:     '#FF0000',
      fillOpacity:   0.05,
      map:           map,
      center:        center,
      radius:        500,
      # draggable:     true
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

  set_current_lat_lng: (lat, lng) ->
    window.current_lat = lat
    window.current_lng = lng
    document.getElementById("current_lat").value = window.current_lat
    document.getElementById("current_lng").value = window.current_lng
    return

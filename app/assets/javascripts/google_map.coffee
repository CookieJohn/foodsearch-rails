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
  window.map           = ''
  window.marker        = ''
  window.circle        = ''
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
    window.map      = new (google.maps.Map)(document.getElementById('map'), mapStyle)
    window.marker   = new (google.maps.Marker)(
      map:       map,
      position:  center,
      draggable: true
    )

    window.circle = google_map.set_circle({lat: lat, lng: lng})
    position.detect_position(false)
    google_map.set_current_lat_lng(lat, lng)

    google_map.resize_map()

    search_input = google_map.set_items_in_map()
    searchBox    = new (google.maps.places.SearchBox)(search_input)

    # drag event
    google.maps.event.addListener marker, 'dragend', (event) ->
      lat = event.latLng.lat()
      lng = event.latLng.lng()

      google_map.set_current_lat_lng(lat, lng)
      map.setCenter new (google.maps.LatLng)(lat, lng)
      google_map.move_circle({lat: lat,lng: lng})
      return

    # drag event
    google.maps.event.addListener circle, 'dragend', (event) ->
      lat = event.latLng.lat()
      lng = event.latLng.lng()

      google_map.set_current_lat_lng(lat, lng)
      map.setCenter new (google.maps.LatLng)(lat, lng)
      marker.setPosition event.latLng
      google_map.move_circle(event.latLng)
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
        google_map.set_current_lat_lng(lat, lng)

        setTimeout ->
          map.setCenter new (google.maps.LatLng)(lat, lng)
          google_map.move_circle({lat: lat,lng: lng})
          marker.setPosition(location)
        , 100
      return

class window.GoogleMap
  set_items_in_map: () ->
    search_input = document.getElementById('address-input')
    clear_button = document.getElementById('clear-search')
    window.map.controls[window.google.maps.ControlPosition.TOP_CENTER].push search_input
    window.map.controls[window.google.maps.ControlPosition.TOP_CENTER].push clear_button
    search_input.style.display = "inline"
    clear_button.style.display = "inline"
    return search_input

  set_circle: (center) ->
    circle_options   = {
      strokeColor:   '#FF0000',
      strokeOpacity: 0.5,
      strokeWeight:  2,
      fillColor:     '#FF0000',
      fillOpacity:   0.05,
      map:           window.map,
      center:        center,
      radius:        500,
      draggable:     true
    }
    window.circle = new google.maps.Circle(circle_options)
    return window.circle

  move_circle: (center) ->
    window.circle.setOptions({center: center})
    return

  resize_map: () ->
    new_height = (window.innerHeight - window.remove_height)
    $('#map').css({'width':'100%','height':"#{new_height}"})
    window.google.maps.event.trigger(window.map, 'resize')
    return

  set_current_lat_lng: (lat, lng) ->
    window.current_lat = lat
    window.current_lng = lng
    document.getElementById("current_lat").value = window.current_lat
    document.getElementById("current_lng").value = window.current_lng
    return

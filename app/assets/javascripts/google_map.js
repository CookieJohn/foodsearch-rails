var current_lat, current_lng;

function initMap() {
  var lat = 25.059651;
  var lng = 121.533380;
  var uluru = {lat: lat, lng: lng};
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 14,
  });
  var marker = new google.maps.Marker({
      map: map,
      draggable: true,
    });

  detect_position(map, marker, uluru);

  var geocoder = new google.maps.Geocoder();
  var loading = document.getElementById('loading');
  google.maps.event.addListener(marker, 'dragend', function (event) {
    lat = event.latLng.lat();
    lng = event.latLng.lng();
    current_lat = lat;
    current_lng = lng;
    map.setCenter(new google.maps.LatLng(lat, lng));
    send_post(current_lat, current_lng);
    geocoder.geocode({
    'latLng': event.latLng
    }, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        if (results[0]) {
          document.getElementById("google_address").innerHTML = results[0].formatted_address;
        }
      }
    });
  });
  if (rails_env == "development"){
    send_post(lat, lng);}
}
function send_post(lat, lng) {
  if (rails_env == "development"){
    url = "http://localhost:3000/refresh_locations"
  }else{
    url = "https://johnwudevelop.tk/refresh_locations"
  }
  $('#loading').show();
  $.ajax({
    url: url,
    type: "POST",
    data: {lat: lat, lng: lng},
    complete: function(e){
      if(e.status == 200){
        $('html, body').animate({
          scrollTop: $("#results_num").position().top
        }, 'slow');
        $('#loading').hide();
      }else{
        alert('載入錯誤，請重新整理網頁。');
        $('#loading').hide();
      }
    }
  });
}

function detect_position(map, marker, uluru) {
  var infoWindow = '';
  $('#loading').show();
  if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function(position) {
      lat = position.coords.latitude;
      lng = position.coords.longitude;
      current_lat = lat;
      current_lng = lng;
      var pos = {
        lat: lat,
        lng: lng
      };
      marker.setPosition(pos);
      map.setCenter(pos);
      $('#loading').hide();
      send_post(lat, lng);
    }, function() {
      handleLocationError(true, infoWindow, map.getCenter(), map, marker, uluru);
    });
  } else {
    handleLocationError(false, infoWindow, map.getCenter(), map, marker, uluru);
  }
}

function handleLocationError(browserHasGeolocation, infoWindow, pos, map, marker, uluru) {
  marker.setPosition(uluru);
  map.setCenter(uluru);
  $('#loading').hide();
}
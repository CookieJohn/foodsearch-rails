function initMap() {
  var uluru = {lat: 25.059651, lng: 121.533380};
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 14,
    // center: uluru,
  });
  // var infoWindow = new google.maps.InfoWindow({map: map});
  var infoWindow = '';
  var marker = new google.maps.Marker({
      map: map,
      draggable: true,
    });
    // Try HTML5 geolocation.
    $('#loading').show();
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var pos = {
          lat: position.coords.latitude,
          lng: position.coords.longitude
        };
        // map.setCenter(pos);

        // infoWindow.setPosition(pos);
        // infoWindow.setContent('您的位置');

        marker.setPosition(pos);
        map.setCenter(pos);
        $('#loading').hide();
      }, function() {
        handleLocationError(true, infoWindow, map.getCenter(), map, marker, uluru);
      });
    } else {
      // Browser doesn't support Geolocation
      handleLocationError(false, infoWindow, map.getCenter(), map, marker, uluru);
    }

  // var marker = new google.maps.Marker({
  //   position: uluru,
  //   map: map,
  //   draggable: true,
  // });
  var geocoder = new google.maps.Geocoder();
  var loading = document.getElementById('loading');
  google.maps.event.addListener(marker, 'dragend', function (event) {
    lat = event.latLng.lat();
    lng = event.latLng.lng();
    $('#loading').show();
    map.setCenter(new google.maps.LatLng(lat, lng));
    send_post();
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
}
function send_post() {
  if (rails_env == "development"){
    url = "http://localhost:3000/refresh_locations"
  }else{
    url = "https://johnwudevelop.tk/refresh_locations"
  }
  $.ajax({
    url: url,
    type: "POST",
    data: {lat: lat, lng: lng},
    success: function(resp){
      $('html, body').animate({
        scrollTop: $("#location_1").offset().top
      }, 'slow');
      $('#loading').hide();
    }
  });
}

function handleLocationError(browserHasGeolocation, infoWindow, pos, map, marker, uluru) {
  // infoWindow.setPosition(pos);
  // infoWindow.setContent(browserHasGeolocation ?
  //                       '讀取所在位置失敗。' :
  //                       '您的裝置不支援定位。');
  marker.setPosition(uluru);
  map.setCenter(uluru);
  $('#loading').hide();
}
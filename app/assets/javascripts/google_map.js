function initMap() {
  var uluru = {lat: 25.059651, lng: 121.533380};
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 14,
    center: uluru,
  });
  // var image = {
  //   anchor: new google.maps.Point(0, 32),
  //   origin: new google.maps.Point(0, 0),
  //   scaledSize: new google.maps.Size(32, 32),
  //   size: new google.maps.Size(64, 64),
  //   url: "/assets/spoon.png"
  // };
  var marker = new google.maps.Marker({
    position: uluru,
    map: map,
    draggable: true,
  });
  var geocoder = new google.maps.Geocoder();
  google.maps.event.addListener(marker, 'dragend', function (event) {
    lat = event.latLng.lat();
    lng = event.latLng.lng();
    // document.getElementById("lat").innerHTML = "經度：" + lat;
    // document.getElementById("lng").innerHTML = "緯度：" + lng;
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
  $('#loading').show();
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
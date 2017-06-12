function initMap() {
  var uluru = {lat: 25.059651, lng: 121.533380};
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 14,
    center: uluru,
  });
  var marker = new google.maps.Marker({
    position: uluru,
    map: map,
    draggable: true,
  });
  var geocoder = new google.maps.Geocoder();
  google.maps.event.addListener(marker, 'dragend', function (event) {
    lat = event.latLng.lat();
    lng = event.latLng.lng();
    document.getElementById("lat").innerHTML = "經度：" + lat;
    document.getElementById("lng").innerHTML = "緯度：" + lng;
    if (rails_env == "development"){
      url = "http://localhost:3000/refresh_locations"
      // url = "https://johnwudevelop.tk/refresh_locations"
    }else{
      // url = "http://localhost:3000/refresh_locations"
      url = "https://johnwudevelop.tk/refresh_locations"
    }
    $('#loading').show();
    $.ajax({
      url: url,
      type: "POST",
      data: {lat: lat, lng: lng},
      success: function(resp){
        $('#loading').hide();
      }
    });
    geocoder.geocode({
    'latLng': event.latLng
    }, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        if (results[0]) {
          document.getElementById("google_address").innerHTML = "地址：" + results[0].formatted_address;
        }
      }
    });
  });
}
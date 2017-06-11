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
    // document.getElementById("google_address").innerHTML = "地址：" + results[0].formatted_address;
    document.getElementById("lat").innerHTML = "經度：" + event.latLng.lat();
    document.getElementById("lng").innerHTML = "緯度：" +event.latLng.lng();
    // alert(document.getElementById("lat").value);
    geocoder.geocode({
    'latLng': event.latLng
    }, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        if (results[0]) {
          document.getElementById("google_address").innerHTML = "地址：" + results[0].formatted_address;
          // alert(results[0].formatted_address);
        }
      }
    });
  });
}
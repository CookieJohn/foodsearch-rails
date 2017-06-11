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
}
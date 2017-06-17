function SelectMode(current_lat, current_lng) {
	var s = document.getElementById('select-mode');
	var value = s[s.selectedIndex].value;
  document.cookie = "mode=" + value;
  if (current_lat != 0.0 && current_lng != 0.0) {
  	send_post(current_lat, current_lng);
  }
}
function SelectMode() {
	var s = document.getElementById('select-mode');
	var value = s[s.selectedIndex].value;
  document.cookie = "mode=" + value;
  if (typeof current_lat != 'undefined' &&  typeof current_lng != 'undefined') {
  	send_post(current_lat, current_lng);
  }
}
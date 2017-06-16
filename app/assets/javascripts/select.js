function SelectMode() {
	var s = document.getElementById('select-mode');
	var value = s[s.selectedIndex].value;
  document.cookie = "mode=" + value;
}
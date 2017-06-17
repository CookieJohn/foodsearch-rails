// map-icon
$(document).on('click', '#map-link', function(event){
  event.preventDefault();
  $('html, body').animate({ scrollTop: 0 }, "slow");
  return false;
});
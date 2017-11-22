$(document).on 'click', '#up-link', (event) ->
  event.preventDefault()
  $('html, body').animate { scrollTop: 0 }, 'slow'
  false

$(document).on 'click', '#clearbutton', (event) ->
  event.preventDefault()
  document.getElementById('searchbox').value = ''
  return

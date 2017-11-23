$(document).on 'click', '#up-link', (event) ->
  event.preventDefault()
  $('html, body').animate { scrollTop: 0 }, 'slow'
  false

$(document).on 'click', '#clear-search', (event) ->
  event.preventDefault()
  document.getElementById('pac-input').value = ''
  return

$(document).on 'click', '#select-complete', (event) ->
  # event.preventDefault()
  $('#loading').show()
  return

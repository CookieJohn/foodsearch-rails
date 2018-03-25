$ ->
  position = new Position

  $(document).on 'click', '#up-link', (event) ->
    event.preventDefault()
    $('html, body').animate { scrollTop: 0 }, 'slow'
    false

  $(document).on 'click', '#clear-search', (event) ->
    event.preventDefault()
    document.getElementById('address-input').value = ''
    return

  $(document).on 'click', '#locate-button', (event) ->
    event.preventDefault()
    position.detect_position()
    return

  $(document).on 'click', '#select-complete', (event) ->
    $('#loading').show()
    return

  $(document).on 'click', '#ban-icon', (e) ->
    e.preventDefault()
    $(this).parent().parent().remove()
    old_num = parseInt($('#results_num').html().replace( /[^\d.]/g, '' ), 10)
    new_num = old_num - 1
    $('#results_num').html($('#results_num').html().replace(old_num, new_num))
    return

  $(document).on 'click', '#zh-tw-locale', (event) ->
    event.preventDefault()
    set_locale('zh-TW')
    return

  $(document).on 'click', '#ja-locale', (event) ->
    event.preventDefault()
    set_locale('ja')
    return

  $(document).on 'click', '#ko-locale', (event) ->
    event.preventDefault()
    set_locale('ko')
    return

  $(document).on 'click', '#en-locale', (event) ->
    event.preventDefault()
    set_locale('en')
    return

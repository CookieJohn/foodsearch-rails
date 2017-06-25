local_post_url = 'http://localhost:3000/refresh_locations'
production_post_url = 'https://johnwudevelop.tk/refresh_locations'

$ ->
  window.send_post = (lat, lng) ->
    if rails_env == 'development'
      url = local_post_url
    else
      url = production_post_url
    $('#loading').show()
    $.ajax
      url: url
      type: 'POST'
      data:
        lat: lat
        lng: lng
      complete: (e) ->
        if e.status == 200
          $('html, body').animate { scrollTop: $('#locations').position().top }, 'slow'
          $('#loading').hide()
        else
          alert '載入錯誤，請重新整理網頁。'
          $('#loading').hide()
        return
    return

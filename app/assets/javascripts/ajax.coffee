local_post_url = 'http://localhost:3000/refresh_locations'
production_post_url = 'https://johnwudevelop.tk/refresh_locations'

$ ->
  window.send_post = (lat, lng) ->
    url = if rails_env == 'development' then local_post_url else production_post_url
    $('#loading').show()
    $.ajax
      url: url
      type: 'POST'
      data:
        lat: lat
        lng: lng
      complete: (e) ->
        if e.status == 200
          $('#loading').hide()
          $('html, body').animate { scrollTop: $('#results_num').position().top }, 'slow'
        else
          alert '載入錯誤，請重新整理網頁。'
          $('#loading').hide()
        return
    return


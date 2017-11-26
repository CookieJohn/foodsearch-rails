local_post_url = 'http://localhost:3000/refresh_locations'
production_post_url = 'https://johnwudevelop.tk/refresh_locations'
local_set_locale_url = 'http://localhost:3000/set_locale'
production_set_locale_url = 'https://johnwudevelop.tk/set_locale'

$ ->
  window.send_post = (lat, lng) ->
    url = if rails_env == 'development' then local_post_url else production_post_url
    $('#loading').show()
    search_type = document.getElementById('searchbox').value
    $.ajax
      url: url
      type: 'POST'
      data:
        lat: lat
        lng: lng
        search_type: search_type
      complete: (e) ->
        if e.status == 200
          $('#loading').hide()
          window.search_bar_toggle()
          window.scroll_to_card()
        else
          alert '載入錯誤，請重新整理網頁。'
          $('#loading').hide()
        return
    return

  window.set_locale = (locale) ->
    url = if rails_env == 'development' then local_set_locale_url else production_set_locale_url
    $.ajax
      url: url
      type: 'POST'
      data:
        locale: locale
      complete: (e) ->
        if e.status == 200
          window.location.reload(true)
        else
        return
    return

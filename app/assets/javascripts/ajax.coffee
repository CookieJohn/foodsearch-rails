local_post_url = 'http://localhost:3000/refresh_locations'
production_post_url = 'https://johnwudevelop.tk/refresh_locations'

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
          match = document.cookie.match(new RegExp('display=([^;]+)'));
          cookie = match[0].split('=')
          window.search_bar_toggle()
          if cookie[1] == 'wrap'
            $('html, body').animate { scrollTop: $('#results_num').position().top }, 'slow'
          else
            $('html, body').animate { scrollTop: $('#locations').position().top }, 'slow'
            element =  document.getElementById('location_1');
            if typeof element != 'undefined' && element != null
              $('#locations').animate { scrollLeft: $('#location_1').position().left }, 'slow'
        else
          alert '載入錯誤，請重新整理網頁。'
          $('#loading').hide()
        return
    return


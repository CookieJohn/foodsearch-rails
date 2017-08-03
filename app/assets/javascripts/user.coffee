local_post_url = 'http://localhost:3000/users/'
production_post_url = 'https://johnwudevelop.tk/users/'

$(document).on 'ready page:load', ->
	max_distance = document.getElementById("max_distance")
	max_distance_value = document.getElementById("max_distance_value")

	max_distance.addEventListener 'input', (->
	  max_distance_value.value = max_distance.value + '公尺'
	  return
	), false

$(document).on 'ready page:load', ->
	min_score = document.getElementById("min_score")
	min_score_value = document.getElementById("min_score_value")

	min_score.addEventListener 'input', (->
	  min_score_value.value = min_score.value + '分'
	  return
	), false

$(document).on 'click', '#save_user_setting', (event) ->
  max_distance = document.getElementById("max_distance").value
  min_score = document.getElementById("min_score").value
  random_type = document.getElementById("random").checked
  user_id = document.getElementById("user_id").innerHTML
  url = if rails_env == 'development' then local_post_url else production_post_url
  url = url + user_id
  $.ajax
    url: url
    type: 'PATCH'
    dataType: "JSON",
    asnyc: true,
    data:
      user: {
      	max_distance: max_distance,
      	min_score: min_score,
      	random_type: random_type
    	}
    complete: (e) ->
      if e.status == 200
        alert('儲存成功！')
      else
        alert("出了點問題。#{e.responseText}")
      return
  return
Koala.configure do |config|
  config.app_id = ENV['APP_ID']
  config.app_secret = ENV['APP_SECRET']
  config.app_access_token = ENV['APP_ACCESS_TOKEN']
  config.access_token = ENV['ACCESS_TOKEN']
end
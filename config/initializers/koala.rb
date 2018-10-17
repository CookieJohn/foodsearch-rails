# frozen_string_literal: true

Koala.configure do |config|
  config.app_id = ENV['facebook_app_id']
  config.app_secret = ENV['facebook_app_secret']
end

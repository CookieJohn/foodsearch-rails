source 'https://rubygems.org'

ruby '2.5.0'

# fornt
gem 'rails', '~> 5.1'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootstrap-sass', '3.3.7'
gem 'sass-rails'
gem 'slim-rails'
gem "font-awesome-rails"
gem 'meta-tags'
gem 'simple_form'

# back
gem 'geocoder'
gem 'friendly_id'
gem 'redis'
gem 'browser', require: true
gem 'puma'

# third-party
gem 'line-bot-api'
gem 'koala'
gem 'httparty'

# db
gem 'pg', '~> 0.20'

# others
gem 'rails-i18n', '~> 5.0.0'

group :production do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
  gem 'heroku-deflater'
end

group :development, :test do
  gem 'byebug'
  gem 'rspec-rails', '~> 3.6'
  gem 'vcr'
  gem "webmock", require: false
end

group :development do
  gem 'capistrano'
  gem 'capistrano-rvm'
  gem 'capistrano-rails'
  gem 'capistrano-passenger'

  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'guard-livereload', '~> 2.5', require: false

  gem 'better_errors'
  gem 'pry'
  gem 'figaro'

  gem 'rubocop', require: false
end

# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.1'

# fornt
gem 'bootstrap-sass', '~> 3.4'
gem 'coffee-rails'
gem 'font-awesome-rails'
gem 'jbuilder'
gem 'jquery-rails'
gem 'meta-tags'
gem 'rails'
gem 'sass-rails'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'simple_form'
gem 'slim-rails'
gem 'turbolinks'
gem 'uglifier'

# back
gem 'browser', require: true
gem 'friendly_id'
gem 'geocoder'
gem 'puma'
gem 'redis'

# third-party
gem 'httparty'
gem 'koala'
gem 'line-bot-api'

# db
gem 'pg', '~> 0.20'

# others
gem 'rails-i18n'

group :production do
  gem 'heroku-deflater'
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end

group :development, :test do
  gem 'byebug'
  gem 'pry'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.6'
  gem 'vcr'
  gem 'webmock', require: false
end

group :development do
  gem 'guard-livereload', '~> 2.5', require: false
  gem 'spring'
  gem 'web-console', '~> 2.0'

  gem 'better_errors'
  gem 'figaro'

  gem 'rubocop', require: false
end

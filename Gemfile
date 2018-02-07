source 'https://rubygems.org'

# fornt
gem 'rails', '~> 5.1'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'bootstrap-sass'
gem 'slim-rails'
gem "font-awesome-rails"
gem 'meta-tags'
gem 'simple_form'

# back
gem 'fuzzy-string-match'
gem 'typhoeus'
gem 'geocoder'
gem 'friendly_id'
gem 'redis'
gem 'browser', require: true

# third-party
gem 'line-bot-api'
gem 'figaro'
gem 'koala'
gem 'httparty'

# db
gem 'pg', '~> 0.20'

# others
gem 'rails-i18n', '~> 5.0.0'

group :production do
  gem 'newrelic_rpm'
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
  gem 'puma'

  gem 'rubocop', require: false
end

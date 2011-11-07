source 'http://rubygems.org'
gem 'rake', '0.8.7'
gem 'rails'

#Migration
gem 'mongo'
gem 'bson'
gem 'bson_ext'
gem 'sequel'

gem 'athena_resource'
gem 'activerecord-import'

gem 'delayed_job'
gem 'acts-as-taggable-on', '~>2.1.0'

# Views and Rendering
gem 'haml'
gem 'sass'
gem 'dynamic_form'
gem 'will_paginate', '~> 3.0.beta'
gem 'high_voltage'
gem 'copycopter_client'
gem 'mail'
gem 'fastercsv'
gem 'jquery-rails', '>= 1.0.12'
gem 's3', '>= 0.3.8'
gem 'jammit'
gem 'jammit-s3', :path => "vendor/gems/jammit-s3-0.6.3"
gem 'comma',     :path => "vendor/gems/comma-0.4.0"

# Authentication and Roles
gem 'devise'
gem 'devise_invitable'
gem 'cancan'

# Validations
gem 'validates_timeliness'

gem 'thin'
gem 'mysql2', '< 0.3'
gem 'escape_utils'
gem 'httparty'
gem 'rack-jsonp-middleware', :require => 'rack/jsonp'
gem 'exceptional'
gem 'newrelic_rpm'
gem 'transitions', :require => ['transitions', 'active_record/transitions']
gem 'sunspot_rails'

group :test do
  gem 'sqlite3-ruby', :require => 'sqlite3'
  gem 'timecop'
end

group :deployment do
  gem 'heroku'
end

group :test, :development do
  gem "rspec-rails", ">= 2.1"
  gem 'shoulda'
  gem 'fakeweb'
  gem 'factory_girl_rails'
  gem 'nokogiri'
  gem 'capybara'
  gem 'launchy'
  gem 'awesome_print', :require => 'ap'
  gem 'uuid'
  gem 'faker'
  gem 'rails-footnotes', '>= 3.7.5.rc4'
end

group :test do
  gem 'cucumber-rails'
  gem 'database_cleaner'
end

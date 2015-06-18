source 'https://rubygems.org'

gem 'rails', '4.2.1'
gem 'pg'
gem 'bcrypt', '~> 3.1.7'
gem 'jsonapi-resources'
gem 'email_validator'
gem 'rack-cors', :require => 'rack/cors'
gem 'httparty', '0.13.3'
gem 'active_zuora'

group :development do
  gem 'guard-rubocop'
end

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  gem 'spring'
  gem 'rspec-rails', '~> 3.0'
  gem 'guard-rspec', require: false
  gem 'guard-bundler', require: false
  gem 'pry'
  gem 'rubocop', require: false
  gem 'dotenv-rails'
end

group :test do
  gem 'shoulda'
  gem 'webmock', require: 'webmock/rspec'
  gem 'factory_girl_rails'
  gem 'faker'
  gem 'timecop'
  gem 'json_spec'
  gem 'vcr'
end

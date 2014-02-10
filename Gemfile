source 'https://rubygems.org'

gem 'rails', '4.0.2'

gem 'bootstrap-sass', '~> 3.1.0'
gem 'chunky_png'
gem 'haml-rails'
gem 'oily_png' # speeds up chunky_png
gem 'paperclip'
gem 'pg'
gem 'phantomjs'
gem 'sidekiq'
gem 'turbolinks'

group :assets do
  gem 'compass-rails'
  gem 'coffee-rails', '~> 4.0.1'
  gem 'sass-rails',   '~> 4.0.1'
  gem 'uglifier',     '>= 1.0.3'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'mocha'
  gem 'rspec'
  gem 'rspec-rails'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
  gem 'aws-sdk'
end

source 'https://rubygems.org'

gem 'rails', '4.2.1'

gem 'bootstrap-sass', '~> 3.3.0'
gem 'diffux-core'
gem 'haml-rails'
gem 'paperclip'
gem 'pg'
gem 'rails-i18n', '~> 4.0.0'
gem 'sidekiq'
gem 'sinatra', '>= 1.3.0', require: nil # for sidekiq
gem 'turbolinks'

group :assets do
  gem 'autoprefixer-rails'
  gem 'coffee-rails', '~> 4.1.0'
  gem 'sass-rails',   '~> 5.0.0'
  gem 'uglifier',     '>= 1.0.3'
end

group :test do
  gem 'capybara'
  gem 'coveralls', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'mocha'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'poltergeist'
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'flamegraph'
  gem 'spring'
  gem 'sqlite3'
end

group :production do
  gem 'unicorn'
  gem 'rails_12factor'
  gem 'aws-sdk'
end

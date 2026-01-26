source 'https://rubygems.org'

ruby '3.2.8'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.1.5', '>= 7.1.5.2'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use sqlite3 as the database for Active Record
# gem 'sqlite3', '>= 1.4'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'grape'
gem 'grape-entity'
gem 'grape_on_rails_routes'
gem 'jbuilder'

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0.1"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# JWT for token generation
gem 'jwt'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri windows ]
  # Testing frameworks
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'rubocop', require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'database_cleaner-active_record'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'simplecov', require: false
end

# Use PostgreSQL as the database for Active Record
gem 'pg'
gem 'rack', '~> 2.2'

# middleware for rate limiting and throttling
gem 'rack-attack'

gem 'jsonapi-serializer'
gem 'pundit'

# Background job processing
gem 'sidekiq', '~> 7.1' # or a newer version
gem 'sidekiq-scheduler'

# Pagination.
gem 'kaminari'

gem 'karafka'
gem "karafka-web", "~> 0.8.2"

source 'https://gem.fury.io/eh-devops/' do
  gem 'eh_protobuf', '1.16.592'
  gem 'eh_protobuf_core', '5.3.0'
  gem 'feature_flag_assistant', '~> 7.0.0'
end

gem 'grape-swagger' # Core OpenAPI generation
gem 'grape-swagger-entity' # Entity documentation support
gem 'grape-swagger-rails' # Rails integration

gem 'grpc'
gem 'grpc-tools'

gem 'faraday'
gem 'httparty'


# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'sidekiq/testing'

require 'simplecov'

# SimpleCov configuration - guard against multiple starts
SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/bin/'

  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Services', 'app/services'
  add_group 'Workers', 'app/workers'
  add_group 'Policies', 'app/policies'
  add_group 'Serializers', 'app/serializers'
  add_group 'API', 'app/api'

  # Set minimum coverage threshold (optional)
  # minimum_coverage 90

  # Track files even if not loaded in tests
  track_files '{app,lib}/**/*.rb'
end
SimpleCov.coverage_dir 'public/coverage'

# Require support files
Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  # ActiveSupport::Testing::TimeHelpers
  config.include ActiveSupport::Testing::TimeHelpers

  # Sidekiq - use fake mode by default (jobs don't execute)
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end

# Shoulda Matchers configuration
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end


# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

require 'sidekiq-scheduler'

run Rails.application
Rails.application.load_server


require 'rack/attack'
use Rack::Attack


# frozen_string_literal: true
require 'rspec'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end



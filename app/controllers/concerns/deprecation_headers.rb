# frozen_string_literal: true

# Module to add deprecation headers to API responses.
# This concern provides methods to notify API clients about deprecated endpoints
# using standard HTTP headers (Deprecation, Sunset, Link) and custom headers
# for easier detection and migration guidance.
#
# Example usage:
#   class ApiController < ApplicationController
#     include DeprecationHeaders
#
#     def index
#       add_deprecation_warning('v1', Date.new(2024, 12, 31), 'v2')
#       # ... rest of the action
#     end
#   end
module DeprecationHeaders
  extend ActiveSupport::Concern
  # Add deprecation warning to API responses
  def add_deprecation_warning(version, sunset_date, successor_version = nil)
    # Standard HTTP deprecation header
    headers['Deprecation'] = "version=\"#{version}\""
    # When this version will be shut down
    headers['Sunset'] = sunset_date.httpdate
    # Link to migration documentation
    migration_url = "https://docs.employmenthero.com/api/migration/#{version}"
    headers['Link'] = "<#{migration_url}>; rel=\"deprecation\""
    # Link to successor version if available
    if successor_version
      successor_url = request.url.gsub("/#{version}/", "/#{successor_version}/")
      headers['Link'] = "<#{successor_url}>; rel=\"successor-version\""
    end
    # Custom header for easier client detection
    headers['X-API-Deprecated'] = 'true'
    headers['X-API-Sunset-Date'] = sunset_date.iso8601
    headers['X-Migration-Guide'] = migration_url
  end
end

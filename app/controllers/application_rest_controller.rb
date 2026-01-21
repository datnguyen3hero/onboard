class ApplicationRestController < ActionController::API
  include ErrorHandling
  include Pundit
  include PaginationHelper

  rescue_from ActiveRecord::ConnectionTimeoutError do |e|
    Rails.logger.error("Connection pool exhausted: #{e.message}")
    # Return 503 Service Unavailable
    render json: {
      error: 'service_unavailable',
      message: 'Database connection pool exhausted. Please try again.'
    }, status: 503
  end
end

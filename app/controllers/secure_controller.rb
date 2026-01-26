class SecureController < ApplicationRestController
  # only open getter for current_user variable
  attr_reader :current_user
  # hook runs before every action in controllers that inherit from SecureController
  before_action :authenticate_user!, :log_connection_stats
  after_action :log_connection_stats

  private

  def authenticate_user!
    # Conditional Assignment (||=): The "or-equals" operator means:
    # "Only do the work on the right if the value on the left is currently nil or false."
    # Extract JWT token from Authorization header
    auth_header = request.headers['Authorization']

    if auth_header.blank? || !auth_header.start_with?('Bearer ')
      render json: { error: 'Unauthorized - No token provided' }, status: :unauthorized
      return
    end

    token = auth_header.split(' ').last

    # Decode and verify JWT token
    decoded = JwtToken.decode(token)

    if decoded.nil?
      render json: { error: 'Unauthorized - Invalid or expired token' }, status: :unauthorized
      return
    end

    # Find user from decoded token
    @current_user ||= User.find_by(id: decoded[:user_id])

    if @current_user.nil?
      render json: { error: 'Unauthorized - User not found' }, status: :unauthorized
    end
  end
end

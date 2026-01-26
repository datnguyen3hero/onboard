module ApiHelpers
  extend Grape::API::Helpers

  def declared_params
    declared(params, include_missing: false)
  end

  def authenticate_user!
    token = headers['Authorization']&.gsub('Bearer ', '')
    error!({ error: 'Unauthorized - No token provided' }, 401) unless token

    decoded = JwtToken.decode(token)
    error!({ error: 'Unauthorized - Invalid token' }, 401) unless decoded

    @current_user = User.find_by(id: decoded[:user_id])
    error!({ error: 'Unauthorized - User not found' }, 401) unless @current_user

    @current_user
  end

  def current_user
    @current_user
  end
end

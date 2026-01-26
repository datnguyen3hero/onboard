class AuthAPI < Grape::API
  helpers ApiHelpers

  resource :auth do
    desc "User login - authenticate and receive JWT token"
    params do
      requires :email, type: String, desc: "User email address"
      requires :password, type: String, desc: "User password"
    end
    post :login do
      user = User.find_by(email: params[:email])

      if user&.authenticate(params[:password])
        # Log successful login
        UserLoginLog.create(user_id: user.id, success: true)

        # Generate JWT token
        token = JwtToken.encode(user_id: user.id, email: user.email)

        status 200
        {
          message: "Login successful",
          token: token,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            timezone: user.timezone
          }
        }
      else
        # Log failed login if user exists
        UserLoginLog.create(user_id: user.id, success: false) if user

        error!({ error: "Invalid email or password" }, 401)
      end
    end

    desc "User registration - create new user account"
    params do
      requires :email, type: String, desc: "User email address"
      requires :password, type: String, desc: "User password (minimum 6 characters)"
      optional :name, type: String, desc: "User name"
      optional :timezone, type: String, default: "UTC", desc: "User timezone"
    end
    post :register do
      user = User.new(declared_params)

      if user.save
        # Generate JWT token
        token = JwtToken.encode(user_id: user.id, email: user.email)

        status 201
        {
          message: "Registration successful",
          token: token,
          user: {
            id: user.id,
            email: user.email,
            name: user.name,
            timezone: user.timezone
          }
        }
      else
        error!({ errors: user.errors.full_messages }, 422)
      end
    end

    desc "Verify JWT token"
    params do
      requires :token, type: String, desc: "JWT token to verify"
    end
    post :verify do
      decoded = JwtToken.decode(params[:token])

      if decoded
        user = User.find_by(id: decoded[:user_id])
        if user
          status 200
          {
            valid: true,
            user: {
              id: user.id,
              email: user.email,
              name: user.name,
              timezone: user.timezone
            }
          }
        else
          error!({ error: "User not found" }, 404)
        end
      else
        error!({ error: "Invalid or expired token" }, 401)
      end
    end
  end
end

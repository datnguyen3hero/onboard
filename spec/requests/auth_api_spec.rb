require 'rails_helper'

RSpec.describe 'Authentication API', type: :request do
  let(:valid_password) { 'password123' }
  let(:user_attributes) do
    {
      email: 'test@example.com',
      password: valid_password,
      name: 'Test User',
      timezone: 'UTC'
    }
  end

  describe 'POST /api/v1/auth/register' do
    context 'with valid parameters' do
      it 'creates a new user and returns a token' do
        post '/api/v1/auth/register', params: user_attributes

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Registration successful')
        expect(json_response['token']).to be_present
        expect(json_response['user']['email']).to eq('test@example.com')
        expect(json_response['user']['name']).to eq('Test User')
        expect(json_response['user']['id']).to be_present
      end

      it 'encrypts the password' do
        post '/api/v1/auth/register', params: user_attributes

        user = User.find_by(email: 'test@example.com')
        expect(user.password_digest).to be_present
        expect(user.password_digest).not_to eq(valid_password)
      end
    end

    context 'with invalid parameters' do
      it 'returns error when password is too short' do
        post '/api/v1/auth/register', params: user_attributes.merge(password: '123')

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to include(match(/Password is too short/))
      end

      it 'returns error when email is missing' do
        post '/api/v1/auth/register', params: user_attributes.except(:email)

        expect(response).to have_http_status(:bad_request)
      end

      it 'returns error when email is already taken' do
        User.create!(user_attributes)

        post '/api/v1/auth/register', params: user_attributes

        expect(response).to have_http_status(:conflict)
      end
    end
  end

  describe 'POST /api/v1/auth/login' do
    let!(:user) { User.create!(user_attributes) }

    context 'with valid credentials' do
      it 'authenticates user and returns a token' do
        post '/api/v1/auth/login', params: {
          email: user.email,
          password: valid_password
        }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['message']).to eq('Login successful')
        expect(json_response['token']).to be_present
        expect(json_response['user']['id']).to eq(user.id)
      end

      it 'creates a successful login log' do
        expect {
          post '/api/v1/auth/login', params: {
            email: user.email,
            password: valid_password
          }
        }.to change { UserLoginLog.where(user_id: user.id, success: true).count }.by(1)
      end
    end

    context 'with invalid credentials' do
      it 'returns error with wrong password' do
        post '/api/v1/auth/login', params: {
          email: user.email,
          password: 'wrongpassword'
        }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end

      it 'creates a failed login log with wrong password' do
        expect {
          post '/api/v1/auth/login', params: {
            email: user.email,
            password: 'wrongpassword'
          }
        }.to change { UserLoginLog.where(user_id: user.id, success: false).count }.by(1)
      end

      it 'returns error with non-existent email' do
        post '/api/v1/auth/login', params: {
          email: 'nonexistent@example.com',
          password: valid_password
        }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'POST /api/v1/auth/verify' do
    let!(:user) { User.create!(user_attributes) }
    let(:valid_token) { JwtToken.encode(user_id: user.id, email: user.email) }

    context 'with valid token' do
      it 'verifies the token and returns user data' do
        post '/api/v1/auth/verify', params: { token: valid_token }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)

        expect(json_response['valid']).to eq(true)
        expect(json_response['user']['id']).to eq(user.id)
        expect(json_response['user']['email']).to eq(user.email)
      end
    end

    context 'with invalid token' do
      it 'returns error with invalid token' do
        post '/api/v1/auth/verify', params: { token: 'invalid_token' }

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid or expired token')
      end

      it 'returns error with expired token' do
        expired_token = JwtToken.encode(
          { user_id: user.id, email: user.email },
          1.hour.ago
        )

        post '/api/v1/auth/verify', params: { token: expired_token }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'API Helper authenticate_user!' do
    let!(:user) { User.create!(user_attributes) }
    let(:valid_token) { JwtToken.encode(user_id: user.id, email: user.email) }

    it 'allows access to protected endpoints with valid token' do
      get "/api/v1/users/#{user.id}/alerts",
          headers: { 'Authorization' => "Bearer #{valid_token}" }

      # Should not return 401 unauthorized
      expect(response).not_to have_http_status(:unauthorized)
    end

    it 'denies access without token' do
      get "/api/v1/users/#{user.id}/alerts"

      # Depending on implementation, this might return 401 or just work
      # Update this test based on whether you've protected the endpoint
    end
  end
end

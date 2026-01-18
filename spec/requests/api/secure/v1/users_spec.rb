require 'rails_helper'

RSpec.describe 'Api::Secure::V1::Users', type: :request do
  let(:user) { create(:user, name: 'Original', email: 'orig@example.com', timezone: 'UTC') }

  describe 'GET /api/secure/v1/users' do
    it 'returns the current user serialized' do
      get '/api/secure/v1/users', headers: auth_header_for(user)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      # serialized_user may be nested under data.data depending on controller wrapping
      attributes = json.dig('data', 'attributes') || json.dig('data', 'data', 'attributes')
      expect(attributes).to be_present
      expect(attributes['email']).to eq('orig@example.com')
    end

    it 'returns unauthorized when missing token' do
      get '/api/secure/v1/users'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /api/secure/v1/users/:id' do
    it 'updates the current user' do
      params = { user: { name: 'Updated', timezone: 'PST' } }
      patch "/api/secure/v1/users/#{user.id}", params: params, headers: auth_header_for(user)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      # controller returns data directly (not JSONAPI format) for update
      expect(json['data']['name']).to eq('Updated')
      expect(user.reload.name).to eq('Updated')
    end
  end

  describe 'DELETE /api/secure/v1/users/:id' do
    it 'deletes the current user' do
      delete "/api/secure/v1/users/#{user.id}", headers: auth_header_for(user)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('User deleted successfully')
      expect(User.exists?(user.id)).to be_falsey
    end
  end

  describe 'PATCH /api/secure/v1/alerts/:id/acknowledge' do
    it 'acknowledges an alert for the current user' do
      alert = create(:alert)
      alert.alert_subscription_models.create!(user: user)

      patch "/api/secure/v1/alerts/#{alert.id}/acknowledge", headers: auth_header_for(user)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['message']).to eq('Alert acknowledged successfully')
    end

    it 'returns bad_request if already acknowledged' do
      alert = create(:alert, status: Alert.statuses[:acknowledged])
      alert.alert_subscription_models.create!(user: user)

      patch "/api/secure/v1/alerts/#{alert.id}/acknowledge", headers: auth_header_for(user)

      expect(response).to have_http_status(:bad_request)
    end
  end
end

require 'rails_helper'

RSpec.describe 'Api::Secure::V1::Alerts', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }

  describe 'GET /api/secure/v1/alerts' do
    it 'returns only current_user alerts ordered desc' do
      a1 = create(:alert, title: 'old', created_at: 2.days.ago)
      a2 = create(:alert, title: 'new', created_at: 1.day.ago)
      # subscribe user to alerts via alert_subscription_models
      a1.alert_subscription_models.create!(user: user)
      a2.alert_subscription_models.create!(user: user)

      get '/api/secure/v1/alerts', headers: auth_header_for(user)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      titles = json['data'].map { |d| d['title'] }
      expect(titles).to eq(['new', 'old'])
    end

    it 'returns unauthorized when missing token' do
      get '/api/secure/v1/alerts'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/secure/v1/alerts/:id' do
    it 'returns the alert when found' do
      alert = create(:alert)
      alert.alert_subscription_models.create!(user: user)

      get "/api/secure/v1/alerts/#{alert.id}", headers: auth_header_for(user)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['id']).to eq(alert.id)
    end

    it 'returns 404 when not found' do
      get "/api/secure/v1/alerts/999999", headers: auth_header_for(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/secure/v1/alerts' do
    it 'creates an alert for the current user' do
      params = { alert: { title: 'New', body: 'Body', active: true, alert_type: 'system', severity: 'low' } }

      expect {
        post '/api/secure/v1/alerts', params: params, headers: auth_header_for(user)
      }.to change { Alert.count }.by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['title']).to eq('New')
    end

    it 'returns validation errors' do
      params = { alert: { title: '', body: 'Body' } }
      post '/api/secure/v1/alerts', params: params, headers: auth_header_for(user)
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json['errors']).to be_present
    end
  end

  describe 'PATCH /api/secure/v1/alerts/:id' do
    it 'updates the alert' do
      alert = create(:alert, title: 'Old')
      alert.alert_subscription_models.create!(user: user)

      params = { alert: { title: 'Updated' } }
      patch "/api/secure/v1/alerts/#{alert.id}", params: params, headers: auth_header_for(user)

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['title']).to eq('Updated')
      expect(alert.reload.title).to eq('Updated')
    end

    it 'returns 404 when updating non-existent alert' do
      patch '/api/secure/v1/alerts/999999', params: { alert: { title: 'X' } }, headers: auth_header_for(user)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/secure/v1/alerts/:id' do
    it 'deletes the alert' do
      # create alert without subscriptions to avoid FK constraint
      alert = create(:alert)

      delete "/api/secure/v1/alerts/#{alert.id}", headers: auth_header_for(user)

      expect(response).to have_http_status(:no_content)
      expect(Alert.exists?(alert.id)).to be_falsey
    end

    it 'returns 404 when not found' do
      delete '/api/secure/v1/alerts/999999', headers: auth_header_for(user)
      expect(response).to have_http_status(:not_found)
    end
  end
end

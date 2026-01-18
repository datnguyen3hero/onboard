require 'rails_helper'

RSpec.describe 'Api::Secure::V1::AlertSubscription', type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:alert) { create(:alert) }

  describe 'POST /api/secure/v1/users/:user_id/alerts/:alert_id/subscribe' do
    context 'when user is authorized' do
      it 'creates a new alert subscription' do
        puts "Before count: #{AlertSubscriptionModel.count}"

        post "/api/secure/v1/users/#{user.id}/subscribe/#{alert.id}",
             headers: auth_header_for(user)

        puts "After count: #{AlertSubscriptionModel.count}"
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body}"

        expect(AlertSubscriptionModel.count).to eq(1)
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['subscribed']).to be true
      end
    end

    context 'when user is unauthorized' do
      it 'returns unauthorized status' do
        post "/api/secure/v1/users/#{other_user.id}/subscribe/#{alert.id}",
             headers: auth_header_for(user)

        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Unauthorized')
      end
    end

    context 'when alert is not found' do
      it 'returns not found status' do
        post "/api/secure/v1/users/#{user.id}/subscribe/invalid_id",
             headers: auth_header_for(user)

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to start_with('Couldn\'t find Alert with')
      end
    end

    it 'returns unauthorized when missing token' do
      post "/api/secure/v1/users/#{user.id}/subscribe/#{alert.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /api/secure/v1/users/:user_id/subscribe/:alert_id' do
    let!(:subscription) { create(:alert_subscription_model, alert_id: alert.id, user_id: user.id) }

    context 'when user is authorized' do
      it 'destroys the alert subscription' do
        expect {
          delete "/api/secure/v1/users/#{user.id}/subscribe/#{alert.id}",
                 headers: auth_header_for(user)
        }.to change(AlertSubscriptionModel, :count).by(-1)

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['subscribed']).to be true
      end
    end

    context 'when user is unauthorized' do
      it 'returns unauthorized status' do
        delete "/api/secure/v1/users/#{other_user.id}/subscribe/#{alert.id}",
               headers: auth_header_for(user)

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when subscription does not exist' do
      it 'returns not_found status' do
        # non_existent_alert = create(:alert, custom_title: 'Non-existent Alert')
        non_existent_alert = create(:alert, title: 'Non-existent Alert')
        delete "/api/secure/v1/users/#{user.id}/subscribe/#{non_existent_alert.id}",
               headers: auth_header_for(user)

        expect(response).to have_http_status(:not_found)
      end
    end
  end


end

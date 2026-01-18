require 'rails_helper'

RSpec.describe AlertSubscriptionModel, type: :model do
  # Association tests
  describe 'associations' do
    it { should belong_to(:alert) }
    it { should belong_to(:user) }
  end

  # Validation tests
  describe 'validations' do
    subject { build(:alert_subscription_model) }

    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:alert_id) }

    describe 'uniqueness validation' do
      let(:user) { create(:user) }
      let(:alert) { create(:alert) }

      it 'validates uniqueness of alert_id scoped to user_id' do
        create(:alert_subscription_model, user: user, alert: alert)
        duplicate_subscription = build(:alert_subscription_model, user: user, alert: alert)

        expect(duplicate_subscription).not_to be_valid
        expect(duplicate_subscription.errors[:alert_id]).to include('is already subscribed for this user')
      end

      it 'allows same alert for different users' do
        user2 = create(:user)
        create(:alert_subscription_model, user: user, alert: alert)
        subscription2 = build(:alert_subscription_model, user: user2, alert: alert)

        expect(subscription2).to be_valid
      end

      it 'allows same user for different alerts' do
        alert2 = create(:alert)
        create(:alert_subscription_model, user: user, alert: alert)
        subscription2 = build(:alert_subscription_model, user: user, alert: alert2)

        expect(subscription2).to be_valid
      end
    end
  end

  # Factory tests
  describe 'factory' do
    it 'has a valid factory' do
      expect(create(:alert_subscription_model)).to be_valid
    end

    it 'creates with associated user and alert' do
      subscription = create(:alert_subscription_model)
      expect(subscription.user).to be_present
      expect(subscription.alert).to be_present
    end

    it 'sets default values correctly' do
      subscription = create(:alert_subscription_model)
      expect(subscription.email_enabled).to be true
      expect(subscription.push_enabled).to be false
    end
  end

  # Database constraint tests
  describe 'database constraints' do
    let(:user) { create(:user) }
    let(:alert) { create(:alert) }

    it 'prevents duplicate subscriptions at database level' do
      create(:alert_subscription_model, user: user, alert: alert)

      expect {
        AlertSubscriptionModel.create!(user: user, alert: alert)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires valid user_id' do
      subscription = build(:alert_subscription_model, user_id: nil)
      expect(subscription).not_to be_valid
    end

    it 'requires valid alert_id' do
      subscription = build(:alert_subscription_model, alert_id: nil)
      expect(subscription).not_to be_valid
    end
  end

  # Integration tests
  describe 'integration' do
    let(:user) { create(:user) }
    let(:alert) { create(:alert) }
    let(:subscription) { create(:alert_subscription_model, user: user, alert: alert) }

    it 'links user to alert correctly' do
      expect(subscription.user).to eq(user)
      expect(subscription.alert).to eq(alert)
    end

    it 'can access alert through user' do
      subscription
      expect(user.alerts).to include(alert)
    end

    it 'can access user through alert' do
      subscription
      expect(alert.users).to include(user)
    end

    it 'updates timestamps on save' do
      subscription
      original_updated_at = subscription.updated_at

      travel 1.hour do
        subscription.update(email_enabled: false)
        expect(subscription.reload.updated_at).to be > original_updated_at
      end
    end
  end

  # Edge cases
  describe 'edge cases' do
    it 'handles boolean fields correctly' do
      subscription = create(:alert_subscription_model, email_enabled: false, push_enabled: true)
      expect(subscription.email_enabled).to be false
      expect(subscription.push_enabled).to be true
    end

    it 'persists changes to boolean fields' do
      subscription = create(:alert_subscription_model, email_enabled: true)
      subscription.update(email_enabled: false)

      expect(subscription.reload.email_enabled).to be false
    end
  end
end


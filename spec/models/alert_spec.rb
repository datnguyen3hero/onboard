require 'rails_helper'

RSpec.describe Alert, type: :model do
  # Association tests
  describe 'associations' do
    it { should have_many(:alert_subscription_models).with_foreign_key(:alert_id) }
    it { should have_many(:users).through(:alert_subscription_models) }
  end

  # Validation tests
  describe 'validations' do
    subject { build(:alert) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:alert_type) }
    it { should validate_inclusion_of(:severity).in_array(%w[low medium high critical]).with_message('must be one of: low, medium, high, critical') }
  end

  # Enum tests
  describe 'enums' do
    it { should define_enum_for(:status).with_values(active: 0, acknowledged: 1, resolved: 2, dismissed: 3).with_prefix(:status) }
  end

  # Scope tests
  describe 'scopes' do
    let!(:active_alert) { create(:alert, active: true, alert_type: 'system', severity: 'high') }
    let!(:inactive_alert) { create(:alert, active: false, alert_type: 'user', severity: 'low') }
    let!(:old_alert) { create(:alert, active: true, created_at: 13.hours.ago) }

    describe '.turned_on' do
      it 'returns only active alerts' do
        expect(Alert.turned_on).to include(active_alert, old_alert)
        expect(Alert.turned_on).not_to include(inactive_alert)
      end
    end

    describe '.of_type' do
      it 'returns alerts of specified type' do
        expect(Alert.of_type('system')).to include(active_alert)
        expect(Alert.of_type('system')).not_to include(inactive_alert)
      end
    end

    describe '.with_severity' do
      it 'returns alerts with specified severity' do
        expect(Alert.with_severity('high')).to include(active_alert)
        expect(Alert.with_severity('high')).not_to include(inactive_alert)
      end

      it 'returns all alerts when severity is blank' do
        expect(Alert.with_severity(nil).count).to eq(3)
      end
    end

    describe '.overdue' do
      it 'returns active alerts older than 12 hours' do
        expect(Alert.overdue).to include(old_alert)
        expect(Alert.overdue).not_to include(active_alert)
      end
    end
  end

  # Class method tests
  describe '.for_user' do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }
    let(:alert1) { create(:alert) }
    let(:alert2) { create(:alert) }

    before do
      create(:alert_subscription_model, user: user, alert: alert1)
    end

    it 'returns alerts subscribed by the user' do
      expect(Alert.for_user(user)).to include(alert1)
      expect(Alert.for_user(user)).not_to include(alert2)
    end

    it 'accepts user id as parameter' do
      expect(Alert.for_user(user.id)).to include(alert1)
      expect(Alert.for_user(user.id)).not_to include(alert2)
    end

    it 'returns distinct alerts' do
      expect(Alert.for_user(user).count).to eq(1)
    end
  end

  describe '.not_for_user' do
    let(:user) { create(:user) }
    let(:alert1) { create(:alert) }
    let(:alert2) { create(:alert) }

    before do
      create(:alert_subscription_model, user: user, alert: alert1)
    end

    it 'returns alerts not subscribed by the user' do
      expect(Alert.not_for_user(user)).to include(alert2)
      expect(Alert.not_for_user(user)).not_to include(alert1)
    end

    it 'accepts user id as parameter' do
      expect(Alert.not_for_user(user.id)).to include(alert2)
      expect(Alert.not_for_user(user.id)).not_to include(alert1)
    end
  end

  # Instance method tests
  describe '#acknowledge' do
    let(:alert) { create(:alert) }

    it 'updates status to acknowledged' do
      alert.acknowledge
      expect(alert.reload.status).to eq('acknowledged')
    end

    it 'sets acknowledged_at timestamp' do
      travel_to Time.current do
        alert.acknowledge
        expect(alert.reload.acknowledged_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe '#resolve' do
    let(:alert) { create(:alert) }

    it 'updates status to resolved' do
      alert.resolve
      expect(alert.reload.status).to eq('resolved')
    end

    it 'sets resolved_at timestamp' do
      travel_to Time.current do
        alert.resolve
        expect(alert.reload.resolved_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe '#overdue?' do
    it 'returns true for active alerts older than 12 hours' do
      alert = create(:alert, active: true, created_at: 13.hours.ago)
      expect(alert.overdue?).to be true
    end

    it 'returns false for active alerts younger than 12 hours' do
      alert = create(:alert, active: true, created_at: 11.hours.ago)
      expect(alert.overdue?).to be false
    end

    it 'returns false for inactive alerts' do
      alert = create(:alert, active: false, created_at: 13.hours.ago)
      expect(alert.overdue?).to be false
    end

    it 'returns false when created_at is nil' do
      alert = build(:alert, active: true, created_at: nil)
      expect(alert.overdue?).to be false
    end
  end

  describe '#high_severity?' do
    it 'returns true for high severity' do
      alert = create(:alert, severity: 'high')
      expect(alert.high_severity?).to be true
    end

    it 'returns true for critical severity' do
      alert = create(:alert, severity: 'critical')
      expect(alert.high_severity?).to be true
    end

    it 'returns false for low severity' do
      alert = create(:alert, severity: 'low')
      expect(alert.high_severity?).to be false
    end

    it 'returns false for medium severity' do
      alert = create(:alert, severity: 'medium')
      expect(alert.high_severity?).to be false
    end
  end

  describe '#acknowledge?' do
    it 'returns true when status is acknowledged' do
      alert = create(:alert, status: :acknowledged)
      expect(alert.acknowledge?).to be true
    end

    it 'returns false when status is not acknowledged' do
      alert = create(:alert, status: :active)
      expect(alert.acknowledge?).to be false
    end
  end

  describe '#mark_overdue' do
    let(:alert) { create(:alert, active: true) }

    it 'sets active to false' do
      alert.mark_overdue
      expect(alert.reload.active).to be false
    end
  end

  # Callback tests
  describe 'callbacks' do
    describe '#set_published_at' do
      it 'sets published_at when active changes from false to true' do
        alert = create(:alert, active: false, published_at: nil)

        travel_to Time.current do
          alert.update(active: true)
          expect(alert.reload.published_at).to be_within(1.second).of(Time.current)
        end
      end

      it 'does not set published_at when active changes from true to false' do
        alert = create(:alert, active: true, published_at: nil)

        alert.update(active: false)
        expect(alert.reload.published_at).to be_nil
      end

      it 'does not set published_at when active remains true' do
        alert = create(:alert, active: true, published_at: nil)

        alert.update(title: 'Updated Title')
        expect(alert.reload.published_at).to be_nil
      end

      it 'does not change published_at on create' do
        alert = create(:alert, active: true, published_at: nil)
        expect(alert.published_at).to be_nil
      end
    end
  end

  # Factory tests
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:alert)).to be_valid
    end

    it 'creates unique titles with sequence' do
      alert1 = create(:alert)
      alert2 = create(:alert)
      expect(alert1.title).not_to eq(alert2.title)
    end
  end
end


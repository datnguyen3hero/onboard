require 'rails_helper'

RSpec.describe UserLoginLog, type: :model do
  # Association tests
  describe 'associations' do
    it { should belong_to(:user) }
  end

  # Factory tests
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user_login_log)).to be_valid
    end

    it 'creates with associated user' do
      log = create(:user_login_log)
      expect(log.user).to be_present
    end

    it 'sets default success to true' do
      log = create(:user_login_log)
      expect(log.success).to be true
    end
  end

  # Attribute tests
  describe 'attributes' do
    let(:user) { create(:user) }

    it 'can track successful login' do
      log = create(:user_login_log, user: user, success: true)
      expect(log.success).to be true
    end

    it 'can track failed login' do
      log = create(:user_login_log, user: user, success: false)
      expect(log.success).to be false
    end

    it 'has timestamps' do
      log = create(:user_login_log, user: user)
      expect(log.created_at).to be_present
      expect(log.updated_at).to be_present
    end
  end

  # Integration tests
  describe 'integration' do
    let(:user) { create(:user) }

    it 'can create multiple login logs for same user' do
      create(:user_login_log, user: user, success: true)
      create(:user_login_log, user: user, success: false)
      create(:user_login_log, user: user, success: true)

      expect(user.user_login_log.count).to eq(3)
    end

    it 'maintains login history order' do
      log1 = create(:user_login_log, user: user, created_at: 3.days.ago)
      log2 = create(:user_login_log, user: user, created_at: 2.days.ago)
      log3 = create(:user_login_log, user: user, created_at: 1.day.ago)

      expect(user.user_login_log.order(created_at: :asc)).to eq([log1, log2, log3])
    end

    it 'tracks success rate' do
      create(:user_login_log, user: user, success: true)
      create(:user_login_log, user: user, success: true)
      create(:user_login_log, user: user, success: false)

      total = user.user_login_log.count
      successful = user.user_login_log.where(success: true).count

      expect(total).to eq(3)
      expect(successful).to eq(2)
      expect(successful.to_f / total).to be_within(0.01).of(0.67)
    end
  end

  # Edge cases
  describe 'edge cases' do
    it 'requires a user' do
      log = build(:user_login_log, user: nil)
      expect(log).not_to be_valid
    end

    it 'can be queried by date range' do
      user = create(:user)
      old_log = create(:user_login_log, user: user, created_at: 10.days.ago)
      recent_log = create(:user_login_log, user: user, created_at: 1.day.ago)

      recent_logs = UserLoginLog.where('created_at > ?', 5.days.ago)

      expect(recent_logs).to include(recent_log)
      expect(recent_logs).not_to include(old_log)
    end

    it 'can filter successful logins' do
      user = create(:user)
      success_log = create(:user_login_log, user: user, success: true)
      fail_log = create(:user_login_log, user: user, success: false)

      successful_logins = UserLoginLog.where(success: true)

      expect(successful_logins).to include(success_log)
      expect(successful_logins).not_to include(fail_log)
    end
  end

  # Business logic tests
  describe 'business logic' do
    let(:user) { create(:user) }

    it 'can track login attempts over time' do
      travel_to Time.current do
        morning_log = create(:user_login_log, user: user, created_at: Time.current.beginning_of_day + 8.hours)
        afternoon_log = create(:user_login_log, user: user, created_at: Time.current.beginning_of_day + 14.hours)
        evening_log = create(:user_login_log, user: user, created_at: Time.current.beginning_of_day + 20.hours)

        today_logs = user.user_login_log.where('created_at >= ?', Time.current.beginning_of_day)

        expect(today_logs.count).to eq(3)
      end
    end

    it 'persists login data correctly' do
      log = create(:user_login_log, user: user, success: false)

      expect(log.reload.success).to be false
      expect(log.user).to eq(user)
    end
  end
end


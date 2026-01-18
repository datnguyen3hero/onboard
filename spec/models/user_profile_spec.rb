require 'rails_helper'

RSpec.describe UserProfile, type: :model do
  # Association tests
  describe 'associations' do
    it { should belong_to(:user) }
  end

  # Validation tests
  describe 'validations' do
    it { should validate_presence_of(:full_name) }
  end

  # Factory tests
  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:user_profile)).to be_valid
    end

    it 'creates with associated user' do
      profile = create(:user_profile)
      expect(profile.user).to be_present
    end

    it 'sets default attributes' do
      profile = create(:user_profile)
      expect(profile.full_name).to eq('John Doe')
      expect(profile.address).to be_present
      expect(profile.date_of_birth).to be_present
    end
  end

  # Validation tests
  describe 'attribute validations' do
    let(:user) { create(:user) }

    it 'is valid with all attributes' do
      profile = build(:user_profile,
        user: user,
        full_name: 'Jane Smith',
        address: '456 Oak Ave',
        date_of_birth: Date.new(1995, 5, 15)
      )
      expect(profile).to be_valid
    end

    it 'is invalid without full_name' do
      profile = build(:user_profile, full_name: nil)
      expect(profile).not_to be_valid
      expect(profile.errors[:full_name]).to include("can't be blank")
    end

    it 'is valid without address' do
      profile = build(:user_profile, address: nil)
      expect(profile).to be_valid
    end

    it 'is valid without date_of_birth' do
      profile = build(:user_profile, date_of_birth: nil)
      expect(profile).to be_valid
    end

    it 'requires a user' do
      profile = build(:user_profile, user: nil)
      expect(profile).not_to be_valid
    end
  end

  # Integration tests
  describe 'integration' do
    let(:user) { create(:user) }

    it 'can be accessed through user association' do
      profile = create(:user_profile, user: user, full_name: 'Alice Johnson')

      expect(user.user_profile).to eq(profile)
      expect(user.user_profile.full_name).to eq('Alice Johnson')
    end

    it 'is destroyed when user is destroyed' do
      profile = create(:user_profile, user: user)
      profile_id = profile.id

      user.destroy

      expect { UserProfile.find(profile_id) }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'enforces one-to-one relationship at database level' do
      create(:user_profile, user: user)

      expect {
        UserProfile.create!(user: user, full_name: 'Another Name')
      }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  # Attribute tests
  describe 'attributes' do
    it 'stores full_name correctly' do
      profile = create(:user_profile, full_name: 'Robert Brown Jr.')
      expect(profile.reload.full_name).to eq('Robert Brown Jr.')
    end

    it 'stores address correctly' do
      profile = create(:user_profile, address: '789 Maple Street, Apt 4B')
      expect(profile.reload.address).to eq('789 Maple Street, Apt 4B')
    end

    it 'stores date_of_birth correctly' do
      profile = create(:user_profile, date_of_birth: Date.new(1988, 12, 25))
      expect(profile.reload.date_of_birth).to eq(Date.new(1988, 12, 25))
    end

    it 'has timestamps' do
      profile = create(:user_profile)
      expect(profile.created_at).to be_present
      expect(profile.updated_at).to be_present
    end
  end

  # Edge cases
  describe 'edge cases' do
    it 'handles long full names' do
      long_name = 'A' * 255
      profile = create(:user_profile, full_name: long_name)
      expect(profile.reload.full_name).to eq(long_name)
    end

    it 'handles special characters in full_name' do
      special_name = "O'Brien-Smith"
      profile = create(:user_profile, full_name: special_name)
      expect(profile.reload.full_name).to eq(special_name)
    end

    it 'handles unicode characters in address' do
      unicode_address = '123 Straße, München, Deutschland'
      profile = create(:user_profile, address: unicode_address)
      expect(profile.reload.address).to eq(unicode_address)
    end

    it 'handles very old dates of birth' do
      old_date = Date.new(1920, 1, 1)
      profile = create(:user_profile, date_of_birth: old_date)
      expect(profile.reload.date_of_birth).to eq(old_date)
    end

    it 'handles future dates of birth' do
      future_date = Date.new(2030, 12, 31)
      profile = create(:user_profile, date_of_birth: future_date)
      expect(profile.reload.date_of_birth).to eq(future_date)
    end
  end

  # Business logic tests
  describe 'business logic' do
    it 'can calculate age from date_of_birth' do
      profile = create(:user_profile, date_of_birth: 30.years.ago.to_date)

      # Manual age calculation
      today = Date.today
      age = today.year - profile.date_of_birth.year
      age -= 1 if today < profile.date_of_birth + age.years

      expect(age).to eq(30)
    end

    it 'can update profile information' do
      profile = create(:user_profile, full_name: 'Old Name', address: 'Old Address')

      profile.update(full_name: 'New Name', address: 'New Address')

      expect(profile.reload.full_name).to eq('New Name')
      expect(profile.reload.address).to eq('New Address')
    end

    it 'updates updated_at timestamp on changes' do
      profile = create(:user_profile)
      original_updated_at = profile.updated_at

      travel 1.hour do
        profile.update(full_name: 'Updated Name')
        expect(profile.reload.updated_at).to be > original_updated_at
      end
    end
  end
end


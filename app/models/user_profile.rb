class UserProfile < ApplicationRecord
  self.table_name = :user_profiles
  belongs_to :user

  validates :full_name, presence: true
end

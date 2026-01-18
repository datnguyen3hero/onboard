FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:token) { SecureRandom.hex(16) }
  end
end


# frozen_string_literal: true
FactoryBot.define do
  factory :alert_subscription_model do
    alert
    user
    email_enabled { true }
    push_enabled { false }
  end
end




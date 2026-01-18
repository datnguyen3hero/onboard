# frozen_string_literal: true
FactoryBot.define do
  factory :user_login_log do
    association :user
    success { true }
  end
end


# frozen_string_literal: true
FactoryBot.define do
  factory :user_profile do
    association :user
    full_name { "John Doe" }
    address { "123 Main St, City, Country" }
    date_of_birth { Date.new(1990, 1, 1) }
  end
end


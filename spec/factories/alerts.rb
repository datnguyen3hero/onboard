FactoryBot.define do
  factory :alert do
    # transient do
    #   custom_title { nil }
    # end
    # title { custom_title || "Test Alert #{SecureRandom.hex(4)}" }

    sequence(:title) { |n| "Test Alert #{n}" }

    body { "Alert body" }
    active { true }
    alert_type { "system" }
    severity { "low" }
    published_at { nil }
  end
end


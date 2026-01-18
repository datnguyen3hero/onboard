class AlertSerializer
  include JSONAPI::Serializer

  attribute :id, :title, :body, :severity

  attribute :created_at do |alert|
    alert.created_at.iso8601
  end

  attribute :updated_at do |alert|
    alert.updated_at.iso8601
  end

  attribute :acknowledged_at do |alert|
    alert.acknowledged_at&.iso8601
  end

  attribute :resolved_at do |alert|
    alert.resolved_at&.iso8601
  end

  attribute :is_overdue do |alert|
    alert.overdue?
  end

  attribute :is_high_priority do |alert|
    alert.high_severity?
  end

  has_many :alert_subscription_models, serializer: AlertSubscriptionModelSerializer
end
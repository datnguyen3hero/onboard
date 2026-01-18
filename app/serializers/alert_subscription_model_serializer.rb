class AlertSubscriptionModelSerializer
  include JSONAPI::Serializer

  attribute :id

  attribute :created_at do |subscription|
    subscription.created_at.iso8601
  end

  attribute :updated_at do |subscription|
    subscription.updated_at.iso8601
  end

  belongs_to :user, serializer: UserSerializer
  belongs_to :alert, serializer: AlertSerializer
end
class UserSerializer
  include JSONAPI::Serializer

  set_type :user
  attribute :id, :name, :email, :timezone, :token

  has_many :alerts, serializer: AlertSerializer
  has_many :alert_subscription_models, serializer: AlertSubscriptionModelSerializer
end
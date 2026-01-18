class AlertSubscriptionModel < ApplicationRecord
  self.table_name = :alert_subscriptions
  belongs_to :alert
  belongs_to :user

  validates :user_id, presence: true
  validates :alert_id, presence: true
  # validates user_id and alert_id presence and uniqueness combination
  validates :alert_id, uniqueness: { scope: :user_id, message: "is already subscribed for this user" }
end

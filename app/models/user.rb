class User < ApplicationRecord
  self.table_name = :users

  # Enable bcrypt password encryption
  has_secure_password

  # in parent table, we use has_many to define one-to-many relationship.
  has_many :user_login_log
  # dependent: :destroy ensures that when a user is deleted, all associated alert subscriptions are also deleted.
  has_many :"alert_subscription_models", foreign_key: :user_id, dependent: :destroy
  has_one :user_profile, foreign_key: :user_id, dependent: :destroy
  # we can also define many-to-many relationship using has_many through.
  has_many :alerts, through: :"alert_subscription_models"

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?

  # b) Write a query to find all users who are subscribed to a specific alert.
  def self.subscribed_to(alert_or_id)
    alert_id = alert_or_id.is_a?(Alert) ? alert_or_id.id : alert_or_id
    joins(:alerts)
      .where(alerts: { id: alert_id })
      .distinct
  end

  def find_alert_by_id(alert_id)
    alerts.find(alert_id)
  end

  def alerts_count
    @alerts_count ||= alerts.count
  end

  private

  def password_required?
    password_digest.nil? || password.present?
  end
end

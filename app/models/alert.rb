class Alert < ApplicationRecord
  self.table_name = :alerts
  has_many :"alert_subscription_models", foreign_key: :alert_id
  has_many :users, through: :"alert_subscription_models"

  validates :title, presence: true
  validates :alert_type, presence: true
  validates :severity, inclusion: {
    in: %w[low medium high critical],
    message: "must be one of: low, medium, high, critical"
  }

  before_update :set_published_at

  # Use scopes for simple, straightforward query conditions that will always return an ActiveRecord::Relation.
  # They're more readable and directly convey the intention of returning a query result.
  scope :turned_on, -> { where(active: true) }
  scope :of_type, ->(type) { where(alert_type: type) }
  scope :with_severity, ->(severity) { where(severity: severity) if severity.present? }
  scope :latest_first, -> { order(created_at: :desc).first }
  scope :overdue, -> {
    where("active = ? AND created_at <= ?", true, 12.hours.ago)
  }

  enum status: {
    active: 0,
    acknowledged: 1,
    resolved: 2,
    dismissed: 3
  }, _prefix: true

  # Use class methods when your query logic is complex, requires conditional logic,
  # or when you might need to return something other than an ActiveRecord::Relation.
  # Class methods offer the full power of Ruby, making them suitable for scenarios where scopes might not be sufficient.

  # a) Write a query to find all alerts a specific user is subscribed to.
  def self.for_user(user_or_id)
    user_id = user_or_id.is_a?(User) ? user_or_id.id : user_or_id

    joins(:alert_subscription_models)
      .where(alert_subscription_models: { user_id: user_id })
      .distinct
  end

  # c) How would you find all users who are not subscribed to a given alert?
  def self.not_for_user(user_or_id)
    user_id = user_or_id.is_a?(User) ? user_or_id.id : user_or_id

    where.not(
      id: joins(:alert_subscription_models)
            .where(alert_subscription_models: { user_id: user_id })
            .select(:id)
    )
  end

  def acknowledge
    update!(
      status: :acknowledged,
      acknowledged_at: Time.current
    )
  end

  def resolve
    update!(
      status: :resolved,
      resolved_at: Time.current
    )
  end

  def overdue?
    return false unless active? && created_at.present?
    Time.current > (created_at + 12.hours)
  end

  def high_severity?
    severity.in?(%w[high critical])
  end

  def acknowledge?
    status == "acknowledged"
  end

  def mark_overdue
    update!(active: false)
  end

  private

  # a) Use an Active Record callback to set the published_at field to the current time (Time.current) only when:
  # The alert is being updated,
  # The active field changes from false to true
  def set_published_at
    if self.active_changed? && self.active == true
      self.published_at = Time.current
    end
  end
end

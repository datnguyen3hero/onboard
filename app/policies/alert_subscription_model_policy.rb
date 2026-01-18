class AlertSubscriptionModelPolicy < ApplicationPolicy
  # method name must be the same as the action name
  def unsubscribe_alerts?
    @user.present? && @record.user_id == @user.id && @user.alert_subscription_models.map(&:alert_id).include?(@record.alert_id)
  end

  def subscribe_alerts?
    @user.present? && @record.alert.present?
  end

end


class AlertSubscriptionPolicy < ApplicationPolicy
  # method name must be the same as the action name
  def unsubscribe_alerts?
    @user.present? && @record.user_id == @user.id
  end

end


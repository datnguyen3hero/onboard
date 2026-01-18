class AlertPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    # allow show if the user is subscribed or user is present
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    user.present?
  end

  def destroy?
    user.present?
  end

  # used for scope function of Record
  # policy_scope(Alert)

  # class Scope < Scope
  #   def resolve
  #     # return alerts the user is subscribed to
  #     if user.present?
  #       Alert.for_user(user)
  #     else
  #       scope.none
  #     end
  #   end
  # end
end


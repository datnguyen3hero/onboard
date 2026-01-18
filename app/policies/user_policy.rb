class UserPolicy < ApplicationPolicy
  # method name must be the same as the action name
  def index?
    @user.present?
  end

end


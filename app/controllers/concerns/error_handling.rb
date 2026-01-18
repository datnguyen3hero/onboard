module ErrorHandling
  extend ActiveSupport::Concern

  included do
    # rescue_from will do exception handling
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    rescue_from ActiveRecord::RecordNotUnique, with: :record_not_unique
  end

  private

  def record_not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def record_invalid(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  def user_not_authorized(_exception)
    render json: { error: "You are not authorized to perform this action." }, status: :forbidden
  end

  def record_not_unique(exception)
    render json: { error: "Record already exists", detail: exception.message }, status: :conflict
  end
end

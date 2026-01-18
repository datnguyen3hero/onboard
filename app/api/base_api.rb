require_relative "helpers/api_helpers"
require_relative "entities/alert_entity"
require_relative "entities/user_entity"
require_relative "resources/users_api"
require_relative "resources/alerts_api"

class BaseApi < Grape::API
  format :json
  prefix :api
  version "v1", using: :path

  helpers ApiHelpers

  # Grape-level exception handling so ActiveRecord DB exceptions (like
  # RecordNotUnique) raised inside Grape endpoints are caught and rendered
  # as JSON responses with proper status codes.
  rescue_from ActiveRecord::RecordNotFound do |e|
    error!({ error: e.message }, 404)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    error!({ errors: e.record.errors.full_messages }, 422)
  end

  rescue_from ActiveRecord::RecordNotUnique do |e|
    # Return 409 Conflict for uniqueness violations (duplicate key)
    error!({ error: 'Record already exists', detail: e.message }, 409)
  end

  rescue_from Pundit::NotAuthorizedError do |_e|
    error!({ error: 'You are not authorized to perform this action.' }, 403)
  end

  mount UsersAPI
  mount AlertsAPI
end


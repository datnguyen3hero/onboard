require_relative "helpers/api_helpers"
require_relative "entities/alert_entity"
require_relative "entities/user_entity"
require_relative "resources/auth_api"
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

  mount AuthAPI
  mount UsersAPI
  mount AlertsAPI

  add_swagger_documentation(
    # Basic API information
    api_version: 'v1',
    hide_documentation_path: true,  # Don't show the /swagger_doc endpoint in docs
    mount_path: '/swagger_doc',      # Where to mount the JSON specification
    hide_format: true,               # Don't show .json in URLs
    # API metadata that appears in documentation
    info: {
      title: 'Alert Management API v1',
      description: 'Public API for alert management system - provides CRUD operations for alerts',
      contact: {
        name: 'API Support Team',
        email: 'api-support@example.com',
        url: 'https://docs.example.com'
      },
      license: {
        name: 'MIT',
        url: 'https://opensource.org/licenses/MIT'
      }
    },

    # Server configuration
    servers: [
      # http://localhost:3000/api/v1/swagger_doc
      {
        url: 'http://localhost:3000/api/v1',
        description: 'Development server'
      }
    ]
  )
end


module Api
  module Secure
    module V1
      class UserController < SecureController
        # before_action
        def index
          # user_alerts = @current_user.alerts.order(created_at: :desc)
          #
          # render json: {
          #   data: user_alerts.map do |alert|
          #     {
          #       id: alert.id,
          #       title: alert.title,
          #       body: alert.body
          #     }
          #   end
          # }
          #
        end
      end
    end
  end
end
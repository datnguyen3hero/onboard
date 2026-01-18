module Api
  module Secure
    module V1
      class AlertSubscriptionController < SecureController
        include Pundit

        before_action :validate_user!
        before_action :find_alert!

        def subscribe_alerts
          # Create a temporary subscription model to authorize
          subscription = @alert.alert_subscription_models.build(user_id: @current_user&.id)
          authorize subscription

          subscription.save!
          render json: { subscribed: true }, status: :created
        end

        def unsubscribe_alerts
          subscription = @alert.alert_subscription_models.find_by!(user_id: @current_user.id)
          authorize subscription

          subscription&.destroy!
          render json: { subscribed: true }, status: :ok
        end

        private

        def validate_user!
          if @current_user&.id != params[:user_id]
            render json: { error: 'Unauthorized' }, status: :unauthorized
            return
          end
        end

        def find_alert!
          @alert = Alert.find(params[:alert_id])
          if @alert.nil?
            render json: { error: 'Alert not found' }, status: :not_found
            return
          end
        end
      end
    end
  end
end
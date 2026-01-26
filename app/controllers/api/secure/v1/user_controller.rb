module Api
  module Secure
    module V1
      class UserController < SecureController
        def index
          # trigger authorization check by pundit
          authorize @current_user

          # user_alerts = @current_user.alerts.order(created_at: :desc)
          # render json: {
          #   data: user_alerts.map do |alert|
          #     {
          #       id: alert.id,
          #       title: alert.title,
          #       body: alert.body
          #     }
          #   end
          # }
          logger.info("Fetching user data for user ID: #{@current_user.id}")
          render json: {
            data: UserSerializer.new(@current_user, include: [:alert_subscription_models, :alerts]).serializable_hash
          }
        end

        def update
          @current_user&.update!(user_params)
          render json: {
            data: {
              id: @current_user&.id,
              name: @current_user&.name,
              email: @current_user&.email,
              timezone: @current_user&.timezone,
              token: @current_user&.token
            }
          }
        end

        def destroy
          @current_user&.destroy!
          render json: { message: 'User deleted successfully' }, status: :ok
        end

        def acknowledge
          add_deprecation_warning('v1', 3.months.from_now, 'v2')

          alert = @current_user&.find_alert_by_id(params[:id])
          acknowledge_result = AlertService.new(alert).acknowledge_alert(@current_user)

          if acknowledge_result
            render json: { message: 'Alert acknowledged successfully' }, status: :ok
          else
            render json: { message: 'Alert already acknowledged' }, status: :bad_request
          end
        end

        private

        def user_params
          params.require(:user).permit(:name, :email, :timezone)
        end
      end
    end
  end
end

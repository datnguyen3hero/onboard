module Api
  module Secure
    module V1
      class AlertController < SecureController
        before_action :find_alert, only: [:show, :update, :destroy]

        def index
          # authorize with class
          # we don't have a particular post to authorize
          authorize Alert
          capped_items_number_per_page = get_capped_items_number_per_page(pagination_params[:item_per_page])

          user_alerts = @current_user.alerts.order(created_at: :desc)
                                     .page(pagination_params[:page_index])
                                     .per(capped_items_number_per_page)
          render json: {
            count: @current_user&.alerts_count,
            data: user_alerts.map do |alert|
              {
                id: alert.id,
                title: alert.title,
                body: alert.body
              }
            end
          }
        end

        def show
          render json: {
            data: @alert.as_json
          }
        end

        def create
          new_alert = @current_user.alerts.build(alert_params)
          save_result = new_alert.save
          if save_result == false
            render json: { errors: new_alert.errors.full_messages }, status: 422
            return
          end

          render json: {
            data: {
              id: new_alert.id,
              title: new_alert.title,
              body: new_alert.body,
              active: new_alert.active,
              type: new_alert.alert_type,
              published_at: new_alert.published_at
            }
          }, status: :created
        end

        def update
          update_result = @alert.update(alert_params)
          if update_result == false
            render json: { errors: @alert.errors.full_messages }, status: 422
            return
          end
          render json: {
            data: {
              id: @alert.id,
              title: @alert.title,
              body: @alert.body,
              active: @alert.active,
              type: @alert.alert_type,
              published_at: @alert.published_at
            }
          }, status: :ok
        end

        def destroy
          # destroy: will run full life-cycle callbacks for example: before_destroy, after_destroy
          # delete: will remove the record from database without running any callbacks
          @alert.destroy
          render json: { message: "Alert deleted successfully" }, status: :no_content
        end

        private

        def find_alert
          # @alert = @current_user.alerts.find_by(id: params[:id])
          # if @alert.nil?
          #   render json: { error: "Alert not found" }, status: 404
          # end
          @alert = Alert.find_by(id: params[:id])
          if @alert.nil?
            render json: { error: "Alert not found" }, status: 404
          end
        end

        def alert_params
          params.require(:alert).permit(:title, :body, :active, :alert_type)
        end

        def pagination_params
          params.permit(:page_index, :item_per_page)
          {
            page_index: params[:page_index].to_i || 1,
            item_per_page: params[:item_per_page].to_i || 20
          }
        end
      end
    end
  end
end
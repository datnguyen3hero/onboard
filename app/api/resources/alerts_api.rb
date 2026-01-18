class AlertsAPI < Grape::API
  helpers ApiHelpers

  resource :alerts do
    desc "Create a new alert"
    params do
      requires :title, type: String
      optional :body, type: String
      optional :active, type: Boolean, default: true
      optional :alert_type, type: String, default: "Alert"
    end
    post do
      alert = Alert.create!(declared_params)
      status 201
      # present method is used to format the response using a specified entity
      present alert, with: Entities::AlertEntity
    end

    desc "List all alerts"
    get do
      alerts = Alert.all.order(created_at: :desc)
      present :data, alerts, with: Entities::AlertEntity
    end

    desc "Users subscribed to an alert"
    params do
      requires :alert_id, type: String
    end
    get ":alert_id/users" do
      present User.subscribed_to(params[:alert_id]), with: Entities::UserEntity
    end

    desc "Update an alert"
    params do
      requires :alert_id, type: String
      optional :title, type: String
      optional :body, type: String
      optional :active, type: Boolean
      optional :alert_type, type: String
    end
    put ":alert_id" do
      alert = Alert.find(params[:alert_id])
      # declared(params, include_missing: false) : parse to only provided params (with optional params, it will not present in hash if not provided)
      # except(:alert_id) : the parser will ignore alert_id param, we don't want to update the alert_id
      updating_alert = declared_params
                         .except(:alert_id)
      alert.update!(updating_alert)
    end

    resource :subscriptions do
      desc "Subscribe a user to an alert"
      params do
        requires :alert_id, type: String
        requires :user_id, type: String
      end
      post ":alert_id" do
        alert = Alert.find(params[:alert_id])
        alert.alert_subscription_models
             .create!(user_id: params[:user_id])
        status 201
        { subscribed: true }
      end

      desc "Unsubscribe a user from an alert"
      params do
        requires :alert_id, type: String
        requires :user_id, type: String
      end
      delete ":alert_id/:user_id" do
        alert = Alert.find(params[:alert_id])
        alert.alert_subscription_models
             .where(user_id: params[:user_id])
             .delete_all
        status 204
        body false
      end
    end
  end
end

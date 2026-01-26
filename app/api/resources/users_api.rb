class UsersAPI < Grape::API
  helpers ApiHelpers

  resource :users do
    desc "Create a new user"
    params do
      requires :name, type: String
      requires :email, type: String
      requires :password, type: String
      optional :timezone, type: String, default: "UTC"
    end
    post do
      user = User.create!(declared_params)
      status 201
      present user, with: Entities::UserEntity
    end

    desc "Alerts a user is subscribed to"
    params do
      requires :user_id, type: String
    end
    get ":user_id/alerts" do
      present Alert.for_user(params[:user_id]), with: Entities::AlertEntity
    end

    desc "Alerts a user is not subscribed to"
    params do
      requires :user_id, type: String
    end
    get ":user_id/unsubscribed_alerts" do
      present Alert.not_for_user(params[:user_id]), with: Entities::AlertEntity
    end
  end
end

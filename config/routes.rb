require 'sidekiq/web'
require 'sidekiq-scheduler/web'
require 'karafka/web'

Rails.application.routes.draw do
  mount BaseApi => '/'

  # expose sidekiq web
  mount Sidekiq::Web => '/sidekiq'

  # expose karafka web
  mount Karafka::Web::App, at: '/karafka'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  get '/health', to: 'system#health'
  get '/stats', to: 'system#stats'

  namespace :api do
    namespace :secure do
      namespace :v1 do
        resources :users, controller: :user, only: [:index, :update, :destroy]
        resources :alerts, controller: :alert, only: [:index, :show, :create, :update, :destroy] do
          member do
            patch 'acknowledge', to: 'user#acknowledge'
            patch 'resolve', to: 'user#resolve'
          end
        end

        # New explicit route for: /api/secure/v1/users/:user_id/subscribe/:alert_id
        post 'users/:user_id/subscribe/:alert_id', to: 'alert_subscription#subscribe_alerts', as: :user_subscribe_alert
        delete 'users/:user_id/subscribe/:alert_id', to: 'alert_subscription#unsubscribe_alerts', as: :user_unsubscribe_alert


        # New explicit route for: /api/secure/v1/users/:user_id/alerts/:alert_id/subscribe
        # post 'users/:user_id/alerts/:alert_id/subscribe', to: 'alert_subscription#subscribe_alerts', as: :user_subscribe_alert
        # delete 'users/:user_id/alerts/:alert_id/subscribe', to: 'alert_subscription#unsubscribe_alerts', as: :user_unsubscribe_alert
      end
    end
  end
end

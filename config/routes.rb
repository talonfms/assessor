# For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  namespace :public, path: "p" do
    resources :survey_responses, param: :token, only: [:show, :create], path: "responses" do
      get :thank_you, on: :member
    end
  end

  draw :accounts
  draw :api
  draw :billing
  draw :turbo_native
  draw :hotwire_native
  draw :users
  draw :dev if Rails.env.local?

  authenticated :user, lambda { |u| u.admin? } do
    draw :madmin
  end

  resources :announcements, only: [:index, :show]

  namespace :action_text do
    resources :embeds, only: [:create], constraints: {id: /[^\/]+/} do
      collection do
        get :patterns
      end
    end
  end

  scope controller: :static do
    get :about
    get :terms
    get :privacy
    get :pricing
    get :reset_app
  end

  match "/404", via: :all, to: "errors#not_found"
  match "/500", via: :all, to: "errors#internal_server_error"

  authenticated :user do
    mount Sidekiq::Web => "/sidekiq"

    root to: "dashboard#show", as: :user_root
    resources :survey_templates
    resources :template_versions do
      resources :blocks, except: %i[index show] do
        member do
          post :reorder
        end
      end
      resources :block_groups, only: [:create]
    end
    resources :block_options, only: %i[create new update destroy]
    resources :assessments do
      member do
        get "download_bundle"
        get "download_analysis"
      end
    end
    resources :finance_checks, only: [:update]
    resources :sow_checks, only: [:update]

    # Alternate route to use if logged in users should still see public root
    # get "/dashboard", to: "dashboard#show", as: :user_root
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", :as => :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Public marketing homepage
  root to: "static#index"
end

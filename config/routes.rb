Rails.application.routes.draw do
  devise_for :users, skip: [ :sessions, :registrations ]

  devise_scope :user do
    get "users/sign_in", to: "devise/sessions#new", as: :new_user_session
    post "users/sign_in", to: "devise/sessions#create", as: :user_session
    delete "users/sign_out", to: "devise/sessions#destroy", as: :destroy_user_session

    scope "users", controller: "devise/registrations" do
      get "sign_up", action: "new", as: :new_user_registration
      post "/", action: "create", as: :user_registration
      get "edit", action: "edit", as: :edit_user_registration
      patch "/", action: "update"
      put "/", action: "update"
      delete "/", action: "destroy"
      get "cancel", action: "cancel", as: :cancel_user_registration
    end
  end

  resources :posts do
    resources :comments, only: [ :create, :destroy ]
    resources :likes, only: [ :create, :destroy ]
  end

  # 设置主页
  root "posts#index"
end

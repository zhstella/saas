Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  
  # --- 这是新的路由逻辑 ---
  
  # 1. 为【已登录】的用户设置根路径 (root)
  # 当用户登录时, 访问 "http://localhost:3000/" 会定向到 posts#index
  authenticated :user do
    root 'posts#index', as: :authenticated_root
  end

  # 2. 为【未登录】的用户设置根路径 (root)
  # 当用户未登录时, 访问 "http://localhost:3000/" 会定向到登录页面
  unauthenticated do
    devise_scope :user do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
  
  # 3. 你的帖子、评论、点赞路由保持不变
  # 我们已经用上面的逻辑替换了旧的 'root "posts#index"'
  resources :posts do
    resources :comments, only: [:create, :destroy]
    resources :likes, only: [:create, :destroy]
  end
end
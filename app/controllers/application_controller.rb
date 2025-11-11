class ApplicationController < ActionController::Base
  # 移除 "except: [:index, :show]"
  # 这一行代码会保护你网站的【所有】页面
  # Devise 的登录/注册页面会自动处理，不受影响
  before_action :authenticate_user!
end
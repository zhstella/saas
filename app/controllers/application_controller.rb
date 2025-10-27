class ApplicationController < ActionController::Base
  # 1. 在这里设置一个“全局”规则：
  # 默认情况下，保护你网站的【所有】页面。
  before_action :authenticate_user!
end
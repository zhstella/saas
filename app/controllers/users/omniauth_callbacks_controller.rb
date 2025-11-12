class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  
  def google_oauth2
    # 1. 调用我们在 User 模型里写的逻辑
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.present?
      # 2A. 登录成功 (是 @columbia.edu 邮箱)
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: 'Google') if is_navigational_format?
    else
      # 2B. 登录失败 (不是 @columbia.edu 邮箱)
      # @user 在 User.from_omniauth 中返回了 nil
      flash[:alert] = 'Access Denied. You must use a @columbia.edu or @barnard.edu email address to log in.'
      redirect_to unauthenticated_root_path
    end
  end

  def failure
    flash[:alert] = 'Login failed. Please try again.'
    redirect_to unauthenticated_root_path
  end
end
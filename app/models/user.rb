class User < ApplicationRecord
  # 1. 你的 Devise 模块
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  # 2. 你的数据关联
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # 3. 修复了“账户链接”逻辑的 OmniAuth 方法
  def self.from_omniauth(auth)
    
    # --- 这是【新】的域名检查逻辑 ---
    allowed_domains = ["@columbia.edu", "@barnard.edu"]
    email_domain = auth.info.email.match(/@(.+)/)[1] # 提取 "@" 后面的所有内容

    unless allowed_domains.include?("@#{email_domain}")
      return nil # 拒绝不在列表中的域名
    end
    # --- 结束新的检查 ---


    # 案例 1: 用户以前用 Google 登录过
    # 正常通过 provider 和 uid 查找
    user = User.find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    # 案例 2: 找不到。尝试通过 email 查找
    # (这处理了“用户先用 Email/Password 注册”的情况)
    user = User.find_by(email: auth.info.email)
    if user
      # 找到了！更新这个用户的 provider 和 uid 来“链接”Google 账户
      user.update(
        provider: auth.provider,
        uid: auth.uid
      )
      return user # 返回这个刚被链接的账户
    end

    # 案例 3: 数据库里完全没有这个用户。创建一个全新的。
    return User.create(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20]
    )
  end
  
end
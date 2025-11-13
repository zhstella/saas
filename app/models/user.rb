require 'securerandom'

class User < ApplicationRecord
  # 1. 你的 Devise 模块
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [ :google_oauth2 ]

  # 2. 你的数据关联
  has_many :posts, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :thread_identities, dependent: :destroy
  has_many :audit_logs, dependent: :destroy
  has_many :performed_audit_logs, class_name: 'AuditLog', foreign_key: :performed_by_id, dependent: :destroy
  has_many :answer_comments, dependent: :destroy
  has_many :post_revisions, dependent: :destroy
  has_many :answer_revisions, dependent: :destroy
  has_many :redacted_posts, class_name: 'Post', foreign_key: :redacted_by_id, dependent: :nullify
  has_many :redacted_answers, class_name: 'Answer', foreign_key: :redacted_by_id, dependent: :nullify

  enum :role, {
    student: 0,
    moderator: 1,
    staff: 2,
    admin: 3
  }, default: :student

  def anonymous_handle
    base = id ? id.to_s(36).upcase.rjust(4, '0') : SecureRandom.alphanumeric(4).upcase
    "Lion ##{base[0, 4]}"
  end

  def can_moderate?
    moderator? || staff? || admin?
  end

  # 3. 修复了"账户链接"逻辑的 OmniAuth 方法
  def self.from_omniauth(auth)
    # --- 这是【新】的域名检查逻辑 ---
    allowed_domains = [ '@columbia.edu', '@barnard.edu' ]
    email_domain = auth.info.email.match(/@(.+)/)[1] # 提取 "@" 后面的所有内容

    unless allowed_domains.include?("@#{email_domain}")
      return nil # 拒绝不在列表中的域名
    end
    # --- 结束新的检查 ---

    # Check moderator whitelist (for all cases)
    moderator_emails = Rails.application.config.moderator_emails || []
    target_role = moderator_emails.include?(auth.info.email) ? :moderator : :student

    # 案例 1: 用户以前用 Google 登录过
    # 正常通过 provider 和 uid 查找
    user = User.find_by(provider: auth.provider, uid: auth.uid)
    if user
      # Update role based on current whitelist
      user.update(role: target_role) if user.role.to_s != target_role.to_s
      return user
    end

    # 案例 2: 找不到。尝试通过 email 查找
    # (这处理了"用户先用 Email/Password 注册"的情况)
    user = User.find_by(email: auth.info.email)
    if user
      # 找到了！更新这个用户的 provider 和 uid 来"链接"Google 账户
      user.update(
        provider: auth.provider,
        uid: auth.uid,
        role: target_role  # Also update role based on whitelist
      )
      return user # 返回这个刚被链接的账户
    end

    # 案例 3: 数据库里完全没有这个用户。创建一个全新的。
    User.create(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email,
      password: Devise.friendly_token[0, 20],
      role: target_role
    )
  end
end

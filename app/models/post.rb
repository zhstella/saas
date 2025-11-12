class Post < ApplicationRecord
  # 关联
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :thread_identities, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy

  after_create :ensure_thread_identity

  # 验证
  validates :title, presence: true
  validates :body, presence: true

  # 辅助方法：检查特定用户是否已点赞
  def liked_by?(user)
    likes.exists?(user: user)
  end

  # 辅助方法：找到特定用户的点赞
  def find_like_by(user)
    likes.find_by(user: user)
  end

  # --- 这是 SQLite 的搜索方法 (替代 pg_search) ---
  def self.search(query)
    if query.present?
      # 一个基础的 WHERE ... LIKE ... 查询，不区分大小写 (iLIKE 适用于 Postgres, LIKE 适用于 SQLite)
      # 为了同时兼容，我们统一转为小写
      where("LOWER(title) LIKE :query OR LOWER(body) LIKE :query", query: "%#{query.downcase}%")
    else
      all
    end
  end

  private

  def ensure_thread_identity
    ThreadIdentity.find_or_create_by!(user: user, post: self)
  end
end

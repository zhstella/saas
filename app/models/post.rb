class Post < ApplicationRecord
  # 关联
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :thread_identities, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy

  after_create :ensure_thread_identity
  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }

  validate :expires_at_within_window

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
    scope = active
    if query.present?
      scope.where("LOWER(title) LIKE :query OR LOWER(body) LIKE :query", query: "%#{query.downcase}%")
    else
      scope
    end
  end

  private

  def ensure_thread_identity
    ThreadIdentity.find_or_create_by!(user: user, post: self)
  end

  def expires_at_within_window
    return if expires_at.blank?

    remaining_days = (expires_at.to_date - Date.current).to_i
    unless remaining_days.between?(7, 30)
      errors.add(:expires_at, 'must be between 7 and 30 days from now')
    end
  end
end

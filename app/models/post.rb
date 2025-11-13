class Post < ApplicationRecord
  # 关联
  belongs_to :user
  belongs_to :topic
  has_many :answers, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :thread_identities, dependent: :destroy
  has_many :audit_logs, as: :auditable, dependent: :destroy
  has_many :post_tags, dependent: :destroy
  has_many :tags, through: :post_tags
  belongs_to :accepted_answer, class_name: 'Answer', optional: true

  after_create :ensure_thread_identity
  scope :active, -> { where('expires_at IS NULL OR expires_at > ?', Time.current) }

  validate :expires_at_within_window
  validate :accepted_answer_belongs_to_post
  validate :tags_within_limit

  # 验证
  validates :title, presence: true
  validates :body, presence: true
  validates :topic, presence: true
  validates :status, presence: true

  STATUSES = {
    open: 'open',
    solved: 'solved',
    locked: 'locked'
  }.freeze
  validates :status, inclusion: { in: STATUSES.values }

  STATUSES.each do |key, value|
    scope "status_#{key}", -> { where(status: value) }

    define_method("status_#{key}?") do
      status == value
    end
  end

  TAG_LIMIT = 5
  MIN_TAGS = 1
  SCHOOLS = [ 'Columbia', 'Barnard' ].freeze

  # 辅助方法：检查特定用户是否已点赞
  def liked_by?(user)
    likes.exists?(user: user)
  end

  # 辅助方法：找到特定用户的点赞
  def find_like_by(user)
    likes.find_by(user: user)
  end

  def locked?
    locked_at.present?
  end

  def lock_with(answer)
    update!(accepted_answer: answer, locked_at: Time.current, status: STATUSES[:solved])
  end

  def unlock!
    update!(accepted_answer: nil, locked_at: nil, status: STATUSES[:open])
  end

  # --- 这是 SQLite 的搜索方法 (替代 pg_search) ---
  def self.search(query)
    PostSearchQuery.new({ q: query }).call
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

  def accepted_answer_belongs_to_post
    return if accepted_answer.blank?

    errors.add(:accepted_answer, 'must belong to this post') if accepted_answer.post_id != id
  end

  def tags_within_limit
    count = tag_ids.compact_blank.size
    if count < MIN_TAGS
      errors.add(:tags, 'must include at least one tag')
    elsif count > TAG_LIMIT
      errors.add(:tags, "cannot include more than #{TAG_LIMIT} tags")
    end
  end
end

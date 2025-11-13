class Answer < ApplicationRecord
  belongs_to :post
  belongs_to :user

  has_many :audit_logs, as: :auditable, dependent: :destroy

  validates :body, presence: true
  validate :post_must_be_open, on: :create

  after_create :ensure_thread_identity
  before_destroy :clear_post_acceptance

  private

  def ensure_thread_identity
    ThreadIdentity.find_or_create_by!(user: user, post: post)
  end

  def clear_post_acceptance
    return unless post.accepted_answer_id == id

    post.update_columns(accepted_answer_id: nil, locked_at: nil, status: Post::STATUSES[:open])
  end

  def post_must_be_open
    return unless post&.locked?

    errors.add(:base, 'This thread is locked. No new answers can be added.')
  end
end

class Comment < ApplicationRecord
  belongs_to :post
  belongs_to :user

  has_many :audit_logs, as: :auditable, dependent: :destroy

  validates :body, presence: true

  after_create :ensure_thread_identity

  private

  def ensure_thread_identity
    ThreadIdentity.find_or_create_by!(user: user, post: post)
  end
end

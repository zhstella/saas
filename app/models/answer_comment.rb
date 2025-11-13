class AnswerComment < ApplicationRecord
  belongs_to :answer
  belongs_to :user

  delegate :post, to: :answer

  validates :body, presence: true

  after_create :ensure_thread_identity

  private

  def ensure_thread_identity
    ThreadIdentity.find_or_create_by!(user: user, post: post)
  end
end

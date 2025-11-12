require 'securerandom'

class ThreadIdentity < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :pseudonym, presence: true
  validates :user_id, uniqueness: { scope: :post_id }

  before_validation :assign_pseudonym

  def self.for(user, post)
    find_or_create_by!(user: user, post: post)
  end

  private

  def assign_pseudonym
    return if pseudonym.present?

    token = SecureRandom.alphanumeric(4).upcase
    self.pseudonym = "Lion ##{token}"
  end
end

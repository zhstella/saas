class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy

  # Provide a stable pseudonym for display without leaking email addresses
  def anonymous_handle
    suffix = id.to_s(36).upcase.rjust(4, '0')
    "Lion ##{suffix}"
  end
end

class Topic < ApplicationRecord
  has_many :posts, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  scope :alphabetical, -> { order(:name) }
end

class Tag < ApplicationRecord
  has_many :post_tags, dependent: :destroy
  has_many :posts, through: :post_tags

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  scope :alphabetical, -> { order(:name) }

  DEFAULT_TAGS = [
    { name: 'Academics', slug: 'academics' },
    { name: 'Courses / COMS', slug: 'courses/coms' },
    { name: 'Advising', slug: 'advising' },
    { name: 'Housing', slug: 'housing' },
    { name: 'Visas & Immigration', slug: 'visas-immigration' },
    { name: 'Financial Aid', slug: 'financial-aid' },
    { name: 'Mental Health', slug: 'mental-health' },
    { name: 'Student Life', slug: 'student-life' },
    { name: 'Career', slug: 'career' },
    { name: 'Marketplace', slug: 'marketplace' },
    { name: 'Accessibility / ODS', slug: 'accessibility-ods' },
    { name: 'Public Safety', slug: 'public-safety' },
    { name: 'Tech Support', slug: 'tech-support' },
    { name: 'International', slug: 'international' },
    { name: 'Resources', slug: 'resources' }
  ].freeze

  def self.seed_defaults!
    DEFAULT_TAGS.each do |attrs|
      find_or_create_by!(slug: attrs[:slug]) do |tag|
        tag.name = attrs[:name]
      end
    end
  end

  private

  def generate_slug
    self.slug = name.parameterize
  end
end

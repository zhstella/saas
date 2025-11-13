class TaxonomySeeder
  TOPICS = [
    'General',
    'Academics',
    'Housing',
    'Wellness',
    'Career',
    'Campus Life'
  ].freeze

  def self.seed!
    new.seed!
  end

  def seed!
    seed_topics
    Tag.seed_defaults!
  end

  private

  def seed_topics
    TOPICS.each do |name|
      Topic.find_or_create_by!(name: name)
    end
  end
end

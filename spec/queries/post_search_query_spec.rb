require 'rails_helper'

RSpec.describe PostSearchQuery do
  let!(:topic_one) { Topic.find_or_create_by!(name: 'Academics') }
  let!(:topic_two) { Topic.find_or_create_by!(name: 'Housing') }
  let!(:tag_one) { Tag.find_or_create_by!(slug: 'academics') { |t| t.name = 'Academics' } }
  let!(:tag_two) { Tag.find_or_create_by!(slug: 'housing') { |t| t.name = 'Housing' } }

  let!(:post_one) do
    create(:post, title: 'Academics help', topic: topic_one).tap { |post| post.update!(tag_ids: [tag_one.id]) }
  end
  let!(:post_two) do
    create(:post, title: 'Housing question', topic: topic_two).tap { |post| post.update!(tag_ids: [tag_two.id]) }
  end

  it 'returns all active posts without filters' do
    results = described_class.new.call
    expect(results).to include(post_one, post_two)
  end

  it 'filters by topic' do
    results = described_class.new({ topic_id: topic_one.id }).call
    expect(results).to include(post_one)
    expect(results).not_to include(post_two)
  end

  it 'filters by tags' do
    results = described_class.new({ tag_ids: [tag_two.id] }).call
    expect(results).to include(post_two)
    expect(results).not_to include(post_one)
  end

  it 'filters by timeframe' do
    post_two.update!(created_at: 40.days.ago)
    results = described_class.new({ timeframe: '30d' }).call
    expect(results).to include(post_one)
    expect(results).not_to include(post_two)
  end
end

require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe 'slug generation' do
    it 'parameterizes the name when slug is blank' do
      tag = build(:tag, name: 'Housing Help', slug: nil)

      expect(tag).to be_valid
      expect(tag.slug).to eq('housing-help')
    end
  end

  describe '.seed_defaults!' do
    it 'creates missing default tags and does not duplicate them' do
      Tag.delete_all

      expect {
        described_class.seed_defaults!
      }.to change(described_class, :count).by(described_class::DEFAULT_TAGS.size)

      expect {
        described_class.seed_defaults!
      }.not_to change(described_class, :count)
    end
  end
end

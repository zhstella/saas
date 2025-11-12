require 'rails_helper'

RSpec.describe ThreadIdentity, type: :model do
  describe '.for' do
    let(:user) { create(:user) }
    let(:post_record) { create(:post) }

    it 'returns the same identity on repeated calls' do
      handle_one = described_class.for(user, post_record)
      handle_two = described_class.for(user, post_record)

      expect(handle_one).to eq(handle_two)
    end

    it 'uses unique pseudonyms for different threads' do
      other_post = create(:post)

      identity_one = described_class.for(user, post_record)
      identity_two = described_class.for(user, other_post)

      expect(identity_one.pseudonym).not_to eq(identity_two.pseudonym)
    end
  end

  it 'generates a pseudonym in the expected format' do
    identity = create(:thread_identity)

    expect(identity.pseudonym).to match(/^Lion #[A-Z0-9]{4}$/)
  end
end

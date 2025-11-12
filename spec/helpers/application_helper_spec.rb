require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#display_author' do
    let(:post_record) { create(:post) }

    before do
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    let(:current_user) { nil }

    it 'returns "Anonymous Student" when user is nil' do
      expect(helper.display_author(nil)).to eq('Anonymous Student')
    end

    it 'returns "You" when the viewer owns the record' do
      allow(helper).to receive(:current_user).and_return(post_record.user)

      expect(helper.display_author(post_record.user, context: post_record)).to eq('You')
    end

    it 'falls back to global anonymous handle when no context is provided' do
      user = create(:user)

      expect(helper.display_author(user)).to eq(user.anonymous_handle)
    end

    it 'returns the thread-specific pseudonym for other participants' do
      other_user = create(:user)
      identity = ThreadIdentity.for(other_user, post_record)

      result = helper.display_author(other_user, context: post_record)

      expect(result).to eq(identity.pseudonym)
    end

    it 'reveals the email when the context flag is true' do
      post_record.update!(show_real_identity: true)

      result = helper.display_author(post_record.user, context: post_record)

      expect(result).to eq(post_record.user.email)
    end

    it 'handles answer contexts via their post' do
      answer = create(:answer, post: post_record)

      identity = ThreadIdentity.for(answer.user, post_record)
      expect(helper.display_author(answer.user, context: answer)).to eq(identity.pseudonym)
    end
  end
end

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#display_author' do
    context 'when user is nil' do
      it 'returns "Anonymous Student"' do
        expect(helper.display_author(nil)).to eq("Anonymous Student")
      end
    end

    context 'when user is the current_user' do
      it 'returns "You"' do
        user = create(:user)
        allow(helper).to receive(:current_user).and_return(user)

        expect(helper.display_author(user)).to eq("You")
      end
    end

    context 'when user is a different user' do
      it 'returns the anonymous handle' do
        current = create(:user)
        other = create(:user)
        allow(helper).to receive(:current_user).and_return(current)

        result = helper.display_author(other)

        expect(result).to match(/^Lion #[A-Z0-9]{4}$/)
        expect(result).to eq(other.anonymous_handle)
      end

      it 'does not return "You"' do
        current = create(:user)
        other = create(:user)
        allow(helper).to receive(:current_user).and_return(current)

        expect(helper.display_author(other)).not_to eq("You")
      end

      it 'does not reveal the email address' do
        current = create(:user)
        other = create(:user, email: "test@example.com")
        allow(helper).to receive(:current_user).and_return(current)

        result = helper.display_author(other)

        expect(result).not_to include("test@example.com")
        expect(result).not_to include("@")
      end
    end

    context 'edge cases' do
      it 'handles when current_user is nil' do
        user = create(:user)
        allow(helper).to receive(:current_user).and_return(nil)

        result = helper.display_author(user)

        expect(result).to eq(user.anonymous_handle)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#anonymous_handle' do
    it 'generates pseudonymous handle based on user ID' do
      user = create(:user)
      handle = user.anonymous_handle

      expect(handle).to match(/^Lion #[A-Z0-9]{4}$/)
      expect(handle).to include(user.id.to_s(36).upcase.rjust(4, "0"))
    end

    it 'generates consistent handles for the same user' do
      user = create(:user)
      first_call = user.anonymous_handle
      second_call = user.anonymous_handle

      expect(first_call).to eq(second_call)
    end

    it 'generates different handles for different users' do
      user1 = create(:user)
      user2 = create(:user)

      expect(user1.anonymous_handle).not_to eq(user2.anonymous_handle)
    end

    it 'generates handles in the format "Lion #XXXX"' do
      user = create(:user)

      expect(user.anonymous_handle).to start_with("Lion #")
      expect(user.anonymous_handle.length).to eq(10) # "Lion #" (6 chars) + 4 digit code = 10
    end
  end

  describe 'associations' do
    it 'has many posts' do
      association = described_class.reflect_on_association(:posts)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many answers' do
      association = described_class.reflect_on_association(:answers)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'has many likes' do
      association = described_class.reflect_on_association(:likes)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'destroys associated posts when user is destroyed' do
      user = create(:user)
      create(:post, user: user)
      create(:post, user: user)

      expect {
        user.destroy
      }.to change(Post, :count).by(-2)
    end

    it 'destroys associated answers when user is destroyed' do
      user = create(:user)
      post = create(:post)
      create(:answer, user: user, post: post)

      expect {
        user.destroy
      }.to change(Answer, :count).by(-1)
    end

    it 'destroys associated likes when user is destroyed' do
      user = create(:user)
      post = create(:post)
      create(:like, user: user, post: post)

      expect {
        user.destroy
      }.to change(Like, :count).by(-1)
    end
  end
end

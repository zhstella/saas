require 'rails_helper'

RSpec.describe Like, type: :model do
  it 'is valid with unique user and post combination' do
    like = build(:like)
    expect(like).to be_valid
  end

  it 'is invalid if the same user likes the same post twice' do
    user = create(:user)
    post = create(:post, user: user)
    create(:like, user: user, post: post)

    duplicate_like = build(:like, user: user, post: post)
    expect(duplicate_like).not_to be_valid
    expect(duplicate_like.errors[:user_id]).to include('has already been taken')
  end

  describe '#find_like_by and #liked_by?' do
    it 'detects when a user has liked a post' do
      user = create(:user)
      post = create(:post)
      create(:like, user: user, post: post)

      expect(post.liked_by?(user)).to be true
      expect(post.find_like_by(user)).to be_a(Like)
    end

    it 'returns false/nil when a user has not liked the post' do
      user = create(:user)
      post = create(:post)

      expect(post.liked_by?(user)).to be false
      expect(post.find_like_by(user)).to be_nil
    end
  end
end

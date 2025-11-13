require 'rails_helper'

RSpec.describe Post, type: :model do
  it 'is valid with valid attributes' do
    post = build(:post)
    expect(post).to be_valid
  end

  it 'is invalid without a title' do
    post = build(:post, title: nil)
    expect(post).not_to be_valid
    expect(post.errors[:title]).to include("can't be blank")
  end

  it 'is invalid without a body' do
    post = build(:post, body: nil)
    expect(post).not_to be_valid
    expect(post.errors[:body]).to include("can't be blank")
  end

  it 'is invalid without a topic' do
    post = build(:post, topic: nil)
    expect(post).not_to be_valid
    expect(post.errors[:topic]).to include("can't be blank")
  end

  it 'requires at least one tag' do
    post = build(:post)
    post.tags = []
    expect(post).not_to be_valid
    expect(post.errors[:tags]).to include('must include at least one tag')
  end

  it 'limits tags to five' do
    post = build(:post)
    extra_tags = create_list(:tag, 6)
    post.tag_ids = extra_tags.map(&:id)
    expect(post).not_to be_valid
    expect(post.errors[:tags]).to include('cannot include more than 5 tags')
  end

  it 'creates a thread identity after creation' do
    post = create(:post)

    identity = ThreadIdentity.find_by(user: post.user, post: post)
    expect(identity).to be_present
  end

  describe '#expires_at_within_window' do
    it 'allows nil expiration' do
      post = build(:post, expires_at: nil)
      expect(post).to be_valid
    end

    it 'rejects expirations shorter than 7 days' do
      post = build(:post, expires_at: 3.days.from_now)
      expect(post).not_to be_valid
      expect(post.errors[:expires_at]).to include('must be between 7 and 30 days from now')
    end

    it 'rejects expirations longer than 30 days' do
      post = build(:post, expires_at: 40.days.from_now)
      expect(post).not_to be_valid
      expect(post.errors[:expires_at]).to include('must be between 7 and 30 days from now')
    end

    it 'accepts expirations within the 7-30 day window' do
      post = build(:post, expires_at: 10.days.from_now)
      expect(post).to be_valid
    end
  end

  describe '.search' do
    let!(:matching_post) { create(:post, title: 'Housing tips', body: 'Advice on Columbia housing') }
    let!(:non_matching_post) { create(:post, title: 'Dining hall review', body: 'Food is great') }

    it 'returns posts that include the query in the title' do
      results = Post.search('housing')
      expect(results).to include(matching_post)
      expect(results).not_to include(non_matching_post)
    end

    it 'returns all posts when the query is blank' do
      expect(Post.search(nil)).to contain_exactly(matching_post, non_matching_post)
    end
  end

  describe '#lock_with' do
    it 'marks the post as solved when locking' do
      post = create(:post)
      answer = create(:answer, post: post)

      post.lock_with(answer)

      expect(post).to be_status_solved
    end

    it 'reopens the post when unlocking' do
      post = create(:post)
      answer = create(:answer, post: post)
      post.lock_with(answer)

      post.unlock!

      expect(post).to be_status_open
    end
  end
end

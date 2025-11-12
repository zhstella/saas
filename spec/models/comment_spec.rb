require 'rails_helper'

RSpec.describe Comment, type: :model do
  it 'is valid with required attributes' do
    comment = build(:comment)
    expect(comment).to be_valid
  end

  it 'is invalid without a body' do
    comment = build(:comment, body: nil)
    expect(comment).not_to be_valid
    expect(comment.errors[:body]).to include("can't be blank")
  end

  it 'belongs to a post and user' do
    comment = create(:comment)
    expect(comment.post).to be_present
    expect(comment.user).to be_present
  end

  it 'creates a thread identity after creation' do
    comment = create(:comment)

    identity = ThreadIdentity.find_by(user: comment.user, post: comment.post)
    expect(identity).to be_present
  end
end

require 'rails_helper'

RSpec.describe Answer, type: :model do
  it 'is valid with required attributes' do
    answer = build(:answer)
    expect(answer).to be_valid
  end

  it 'is invalid without a body' do
    answer = build(:answer, body: nil)
    expect(answer).not_to be_valid
    expect(answer.errors[:body]).to include("can't be blank")
  end

  it 'belongs to a post and user' do
    answer = create(:answer)
    expect(answer.post).to be_present
    expect(answer.user).to be_present
  end

  it 'creates a thread identity after creation' do
    answer = create(:answer)

    identity = ThreadIdentity.find_by(user: answer.user, post: answer.post)
    expect(identity).to be_present
  end

  it 'clears acceptance if the answer is destroyed' do
    post = create(:post)
    answer = create(:answer, post: post)
    post.update(accepted_answer: answer, locked_at: Time.current)

    expect { answer.destroy }.to change { post.reload.accepted_answer }.to(nil)
    expect(post.locked?).to be_falsey
  end
end

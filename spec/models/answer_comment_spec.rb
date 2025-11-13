require 'rails_helper'

RSpec.describe AnswerComment, type: :model do
  it "requires a body" do
    comment = build(:answer_comment, body: '')

    expect(comment).not_to be_valid
    expect(comment.errors[:body]).to include("can't be blank")
  end

  it "delegates the post through the answer" do
    comment = build(:answer_comment)

    expect(comment.post).to eq(comment.answer.post)
  end
end

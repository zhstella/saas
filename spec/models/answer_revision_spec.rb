require 'rails_helper'

RSpec.describe AnswerRevision, type: :model do
  it "requires a body" do
    revision = build(:answer_revision, body: nil)

    expect(revision).not_to be_valid
  end
end

require 'rails_helper'

RSpec.describe PostRevision, type: :model do
  it "requires a body" do
    revision = build(:post_revision, body: nil)

    expect(revision).not_to be_valid
  end
end

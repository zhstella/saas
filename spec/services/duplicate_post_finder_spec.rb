require 'rails_helper'

RSpec.describe DuplicatePostFinder do
  it "returns posts that share similar titles" do
    matching = create(:post, title: 'Visa renewal checklist')
    create(:post, title: 'Dorm cooking tips')

    results = described_class.new(title: 'visa renewal', body: '', exclude_id: nil).call

    expect(results).to include(matching)
    expect(results.count).to eq(1)
  end

  it "excludes a provided post id" do
    post = create(:post, title: 'My roommate search')

    results = described_class.new(title: post.title, body: '', exclude_id: post.id).call

    expect(results).to be_empty
  end
end

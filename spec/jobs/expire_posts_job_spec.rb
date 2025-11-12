require 'rails_helper'

RSpec.describe ExpirePostsJob, type: :job do
  it 'deletes posts whose expires_at is in the past' do
    expired_post = create(:post, :expired)
    active_post = create(:post, :expiring_soon)

    expect {
      described_class.perform_now
    }.to change(Post, :count).by(-1)

    expect(Post.exists?(expired_post.id)).to be false
    expect(Post.exists?(active_post.id)).to be true
  end
end

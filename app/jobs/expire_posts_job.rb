class ExpirePostsJob < ApplicationJob
  queue_as :default

  def perform
    Post.where('expires_at <= ?', Time.current).find_each do |post|
      post.destroy
    end
  end
end

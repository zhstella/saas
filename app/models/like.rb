class Like < ApplicationRecord
  belongs_to :post
  belongs_to :user

  # 核心逻辑：一个用户对一个帖子只能点赞一次
  validates :user_id, uniqueness: { scope: :post_id }
end
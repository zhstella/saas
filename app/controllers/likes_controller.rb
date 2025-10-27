class LikesController < ApplicationController
  before_action :set_post

  def create
    @post.likes.create(user: current_user)
    redirect_to @post
  end

  def destroy
    like = @post.find_like_by(current_user)
    like.destroy if like
    redirect_to @post
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end
end
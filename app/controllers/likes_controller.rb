class LikesController < ApplicationController
  before_action :set_post

  # POST /posts/:post_id/upvote
  def upvote
    existing_vote = @post.find_vote_by(current_user)

    if existing_vote
      if existing_vote.upvote?
        # Toggle: remove upvote
        existing_vote.destroy
      else
        # Switch from downvote to upvote
        existing_vote.update!(vote_type: Like::UPVOTE)
      end
    else
      # Create new upvote
      @post.likes.create!(user: current_user, vote_type: Like::UPVOTE)
    end

    redirect_to @post
  end

  # POST /posts/:post_id/downvote
  def downvote
    existing_vote = @post.find_vote_by(current_user)

    if existing_vote
      if existing_vote.downvote?
        # Toggle: remove downvote
        existing_vote.destroy
      else
        # Switch from upvote to downvote
        existing_vote.update!(vote_type: Like::DOWNVOTE)
      end
    else
      # Create new downvote
      @post.likes.create!(user: current_user, vote_type: Like::DOWNVOTE)
    end

    redirect_to @post
  end

  # Legacy create/destroy for backwards compatibility
  def create
    @post.likes.create(user: current_user, vote_type: Like::UPVOTE)
    redirect_to @post
  end

  def destroy
    like = @post.find_like_by(current_user)
    like.destroy if like
    redirect_to @post
  end

  private

  def set_post
    @post = Post.find(params[:post_id] || params[:id])
  end
end

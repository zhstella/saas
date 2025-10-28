class CommentsController < ApplicationController
  before_action :set_post

  def create
    @comment = @post.comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @post, notice: "Comment added."
    else
      render "posts/show", status: :unprocessable_entity
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])

    if @comment.user == current_user
      @comment.destroy
      redirect_to @post, notice: "Comment deleted."
    else
      redirect_to @post, alert: "You do not have permission to delete this comment."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end

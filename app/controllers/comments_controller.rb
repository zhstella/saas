class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [:destroy, :reveal_identity]

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
    if @comment.user == current_user
      @comment.destroy
      redirect_to @post, notice: "Comment deleted."
    else
      redirect_to @post, alert: "You do not have permission to delete this comment."
    end
  end

  def reveal_identity
    if @comment.user == current_user
      if @comment.update(show_real_identity: true)
        AuditLog.record_identity_reveal(auditable: @comment, actor: current_user)
        redirect_to @post, notice: "Your identity is now visible on this comment."
      else
        redirect_to @post, alert: "Unable to reveal identity right now."
      end
    else
      redirect_to @post, alert: "You do not have permission to reveal this identity."
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_comment
    @comment = @post.comments.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end

class AnswerCommentsController < ApplicationController
  before_action :set_post
  before_action :set_answer
  before_action :set_comment, only: :destroy
  before_action :authorize_comment_owner!, only: :destroy

  def create
    @comment = @answer.answer_comments.new(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @post, notice: 'Comment added.'
    else
      redirect_to @post, alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @comment.destroy
    redirect_to @post, notice: 'Comment deleted.'
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_answer
    @answer = @post.answers.find(params[:answer_id])
  end

  def set_comment
    @comment = @answer.answer_comments.find(params[:id])
  end

  def comment_params
    params.require(:answer_comment).permit(:body)
  end

  def authorize_comment_owner!
    return if @comment.user == current_user

    redirect_to @post, alert: 'You do not have permission to manage this comment.'
  end
end

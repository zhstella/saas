class AnswersController < ApplicationController
  before_action :set_post
  before_action :set_answer, only: [ :destroy, :reveal_identity, :accept ]
  before_action :authorize_answer_owner!, only: [ :destroy, :reveal_identity ]
  before_action :authorize_post_owner!, only: [ :accept ]

  def create
    if @post.locked?
      redirect_to @post, alert: 'This thread is locked. No new answers can be added.'
      return
    end

    @answer = @post.answers.new(answer_params)
    @answer.user = current_user

    if @answer.save
      redirect_to @post, notice: 'Answer added.'
    else
      @answers = @post.answers.includes(:user).order(created_at: :asc)
      render 'posts/show', status: :unprocessable_entity
    end
  end

  def destroy
    @answer.destroy
    redirect_to @post, notice: 'Answer deleted.'
  end

  def reveal_identity
    if @answer.update(show_real_identity: true)
      AuditLog.record_identity_reveal(auditable: @answer, actor: current_user)
      redirect_to @post, notice: 'Your identity is now visible on this answer.'
    else
      redirect_to @post, alert: 'Unable to reveal identity right now.'
    end
  end

  def accept
    if @post.accepted_answer_id == @answer.id
      redirect_to @post, notice: 'This answer is already accepted.'
      return
    end

    if @post.locked? && @post.accepted_answer_id.present?
      redirect_to @post, alert: 'Reopen the thread before selecting a new accepted answer.'
      return
    end

    @post.lock_with(@answer)
    redirect_to @post, notice: 'Answer accepted. Thread locked.'
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_answer
    @answer = @post.answers.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end

  def authorize_answer_owner!
    return if @answer.user == current_user

    redirect_to(@post, alert: 'You do not have permission to perform this action.') and return
  end

  def authorize_post_owner!
    return if @post.user == current_user

    redirect_to(@post, alert: 'Only the question author can manage accepted answers.') and return
  end
end

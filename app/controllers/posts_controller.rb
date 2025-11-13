class PostsController < ApplicationController
  before_action :set_post, only: [ :show, :destroy, :reveal_identity, :unlock ]
  before_action :ensure_active_post, only: [ :show, :reveal_identity ]
  before_action :authorize_owner!, only: [ :unlock ]
  before_action :load_taxonomies, only: [ :new, :create, :preview, :index ]

  # GET /posts
  def index
    @filter_form = filter_params.presence || {}.with_indifferent_access
    flash.now[:alert] = "Please enter text to search." if blank_search_requested?
    @posts = PostSearchQuery.new(@filter_form).call
  end

  # GET /posts/1
  def show
    @answer = Answer.new
    @answers = @post.answers.includes(:user).order(created_at: :asc)
  end

  # GET /posts/new
  def new
    @post = Post.new
  end

  def preview
    @post = current_user.posts.new(post_params)
    @show_preview = true
    render :new, status: :ok
  end

  # POST /posts
  def create
    @post = current_user.posts.new(post_params)

    if @post.save
      redirect_to posts_path, notice: "Post was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    if @post.user == current_user
      @post.destroy
      redirect_to posts_url, notice: "Post deleted."
    else
      redirect_to @post, alert: "You do not have permission to delete this post."
    end
  end

  def reveal_identity
    if @post.user == current_user
      if @post.update(show_real_identity: true)
        AuditLog.record_identity_reveal(auditable: @post, actor: current_user)
        redirect_to @post, notice: "Your identity is now visible on this thread."
      else
        redirect_to @post, alert: "Unable to reveal identity."
      end
    else
      redirect_to @post, alert: "You do not have permission to reveal this identity."
    end
  end

  def unlock
    if @post.locked? && @post.accepted_answer.present?
      @post.unlock!
      redirect_to @post, notice: 'Thread reopened.'
    else
      redirect_to @post, alert: 'No accepted answer to unlock.'
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    permitted = params.require(:post).permit(
      :title,
      :body,
      :expires_at,
      :topic_id,
      :school,
      :course_code,
      tag_ids: []
    )
    permitted[:tag_ids] ||= []
    if permitted[:expires_at].blank?
      permitted[:expires_at] = nil
    else
      days = permitted[:expires_at].to_i
      permitted[:expires_at] = days.positive? ? Time.zone.now + days.days : nil
    end
    permitted
  end

  def filter_params
    return {} unless params[:filters].present?

    permitted = params.require(:filters).permit(:q, :topic_id, :status, :school, :course_code, :timeframe, tag_ids: [])
    permitted[:tag_ids] = Array(permitted[:tag_ids]).reject(&:blank?)
    permitted.to_h.with_indifferent_access
  end

  def ensure_active_post
    return if @post.expires_at.blank? || @post.expires_at.future?

    redirect_to posts_path, alert: 'This post has expired.'
  end

  def authorize_owner!
    return if @post.user == current_user

    redirect_to @post, alert: 'You do not have permission to manage this thread.'
  end

  def load_taxonomies
    @topics = Topic.alphabetical
    @tags = Tag.alphabetical
  end

  def blank_search_requested?
    return false unless params[:filters].present?

    query_blank = @filter_form[:q].blank?
    other_blank = Array(@filter_form[:tag_ids]).reject(&:blank?).empty? &&
                  @filter_form[:topic_id].blank? &&
                  @filter_form[:status].blank? &&
                  @filter_form[:school].blank? &&
                  @filter_form[:course_code].blank? &&
                  @filter_form[:timeframe].blank?

    query_blank && other_blank
  end
end

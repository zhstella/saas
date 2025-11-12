class PostsController < ApplicationController
  before_action :set_post, only: [ :show, :destroy, :reveal_identity ]
  before_action :ensure_active_post, only: [ :show, :reveal_identity ]

  # GET /posts
  def index
    base_scope = Post.active.order(created_at: :desc)
    if params.key?(:search)
      if params[:search].present?
        @posts = Post.search(params[:search]).order(created_at: :desc)
      else
        flash.now[:alert] = "Please enter text to search."
        @posts = base_scope
      end
    else
      @posts = base_scope
    end
  end

  # GET /posts/1
  def show
    @comment = Comment.new
  end

  # GET /posts/new
  def new
    @post = Post.new
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

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    permitted = params.require(:post).permit(:title, :body, :expires_at)
    if permitted[:expires_at].blank?
      permitted[:expires_at] = nil
    else
      days = permitted[:expires_at].to_i
      permitted[:expires_at] = days.positive? ? Time.zone.now + days.days : nil
    end
    permitted
  end

  def ensure_active_post
    return if @post.expires_at.blank? || @post.expires_at.future?

    redirect_to posts_path, alert: 'This post has expired.'
  end
end

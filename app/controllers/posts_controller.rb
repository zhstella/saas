class PostsController < ApplicationController
  # 2. 在这里为 PostsController 设置一个“特例”：
  # “跳过”登录验证，但【仅】针对 :index 和 :show 页面。
  skip_before_action :authenticate_user!, only: [:index, :show]

  before_action :set_post, only: [:show, :destroy]

  # GET /posts 
  def index
    if params[:query].present?
      @posts = Post.search(params[:query]).order(created_at: :desc)
    else
      @posts = Post.all.order(created_at: :desc)
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
      redirect_to @post, notice: 'Post was successfully created!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    if @post.user == current_user
      @post.destroy
      redirect_to posts_url, notice: 'Post deleted.'
    else
      redirect_to @post, alert: 'You do not have permission to delete this post.'
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
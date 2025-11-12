class PostsController < ApplicationController
  before_action :set_post, only: [ :show, :destroy ]

  # GET /posts
  def index
    if params.key?(:search)
      
      if params[:search].present?
        
        # --- 情况 1: 成功搜索 ---
        @posts = Post.search(params[:search]).order(created_at: :desc)
        
      else
        
        # --- 情况 2: 用户提交了空搜索 ---
        flash.now[:alert] = "Please enter text to search."
        @posts = Post.all.order(created_at: :desc)
        
      end
      
    else
      # --- 情况 3: 用户只是刚加载页面 (没有搜索) ---
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

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body)
  end
end
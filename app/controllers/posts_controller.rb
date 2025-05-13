class PostsController < ApplicationController
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :require_login, except: [ :index, :show ]

  def index
    logger.info "Listing all posts"
    @posts = Post.all.order(created_at: :desc)
  end

  def show
    logger.info "Showing post ID: #{@post.id}"
  end

  def new
    logger.info "New post form requested by user ID: #{current_user.id}"
    @post = current_user.posts.new
  end

  def create
    logger.info "Attempting to create post by user ID: #{current_user.id}"
    @post = current_user.posts.new(post_params)

    if @post.save
      logger.info "Post created successfully. ID: #{@post.id}"
      redirect_to @post, notice: "Post was successfully created."
    else
      logger.warn "Post creation failed. Errors: #{@post.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    logger.info "Edit post form requested for post ID: #{@post.id}"
    authorize_user(@post)
  end

  def update
    logger.info "Attempting to update post ID: #{@post.id}"
    authorize_user(@post)

    if @post.update(post_params)
      logger.info "Post updated successfully. ID: #{@post.id}"
      redirect_to @post, notice: "Post was successfully updated."
    else
      logger.warn "Post update failed. Errors: #{@post.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    logger.info "Attempting to delete post ID: #{@post.id}"
    authorize_user(@post)

    if @post.destroy
      logger.info "Post deleted successfully. ID: #{@post.id}"
      redirect_to posts_url, notice: "Post was successfully destroyed."
    else
      logger.error "Failed to delete post ID: #{@post.id}. Errors: #{@post.errors.full_messages.join(', ')}"
      redirect_to @post, alert: "Failed to destroy post.", status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
    logger.debug "Post loaded: ID #{@post.id}"
  rescue ActiveRecord::RecordNotFound => e
    logger.error "Post not found: #{e.message}"
    redirect_to posts_path, alert: "Post not found."
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end

  def authorize_user(post)
    unless post.user == current_user
      logger.warn "Unauthorized attempt to modify post ID: #{post.id} by user ID: #{current_user.id}"
      redirect_to posts_path, alert: "Not authorized to perform this action."
    end
  end

  def require_login
    unless user_signed_in?
      logger.warn "Unauthenticated access attempt to protected resource"
      redirect_to login_path, alert: "You must be logged in to perform this action."
    end
  end
end

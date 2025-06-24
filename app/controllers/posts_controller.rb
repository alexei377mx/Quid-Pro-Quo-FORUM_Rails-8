class PostsController < ApplicationController
  before_action :set_post, only: [ :show, :edit, :update, :destroy, :admin_destroy_post ]
  before_action :authorize_post_owner, only: [ :edit, :update, :destroy ]
  before_action :require_login, except: [ :index, :show, :category ]

  def index
    @posts = Post.where(deleted_by_admin: false).order(created_at: :desc).page(params[:page]).per(10)
  end

  def show
    @post.increment!(:visits)

    if @post.deleted_by_admin
      redirect_to posts_path, alert: t("posts.controller.deleted_by_admin") and return
    end

    @comments = @post.comments.where(parent_id: nil).includes(:user, :replies).order(created_at: :desc)

    if flash[:reply_errors].present?
      @reply_with_errors = Comment.new(
        content: flash[:reply_content],
        parent_id: flash[:reply_parent_id]
      )
      flash[:reply_errors].each { |msg| @reply_with_errors.errors.add(:content, msg) }
    end
  end

  def category
    category_id = params[:category_id].to_s

    if Post::CATEGORIES.key?(category_id.to_i)
      @category_name = Post::CATEGORIES[category_id.to_i]
      @posts = Post.where(category: category_id, deleted_by_admin: false)
                  .order(created_at: :desc).page(params[:page]).per(10)
    else
      @posts = []
      @category_name = nil
      flash[:alert] = t("posts.controller.invalid_category")
    end
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(post_params)

    if @post.save
      redirect_to @post, notice: t("posts.controller.created")
    else
      Rails.logger.error(t("posts.controller.create_failed_log", errors: @post.errors.full_messages.join(", ")))
      flash.now[:alert] = t("posts.controller.create_failed")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    if @post.deleted_by_admin
      redirect_to posts_path, alert: t("posts.controller.deleted_by_admin") and return
    end
  end

  def update
    if @post.deleted_by_admin
      redirect_to posts_path, alert: t("posts.controller.deleted_by_admin") and return
    end

    if @post.update(post_params)
      redirect_to @post, notice: t("posts.controller.updated")
    else
      Rails.logger.error(t("posts.controller.update_failed_log", errors: @post.errors.full_messages.join(", ")))
      flash.now[:alert] = t("posts.controller.update_failed")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @post.destroy
      redirect_to posts_url, notice: t("posts.controller.deleted")
    else
      Rails.logger.error(t("posts.controller.delete_failed_log", id: @post.id, errors: @post.errors.full_messages.join(", ")))
      redirect_to @post, alert: t("posts.controller.delete_failed", id: @post.id, errors: @post.errors.full_messages.join(", ")), status: :unprocessable_entity
    end
  end

  def admin_destroy_post
    authorize! :admin_destroy_post, @post

    if @post.update_column(:deleted_by_admin, true)
      @post.user.check_for_ban!(self)
      redirect_to posts_path, alert: t("posts.controller.admin_deleted")
    else
      Rails.logger.error(t("posts.controller.admin_delete_failed_log", id: @post.id, errors: @post.errors.full_messages.join(", ")))
      redirect_to @post, alert: t("posts.controller.admin_delete_failed")
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content, :category, :image, :remove_image)
  end

  def authorize_post_owner
    unless @post.user == current_user
      Rails.logger.error(t("posts.controller.unauthorized_attempt_log", id: @post.id, user_id: current_user&.id))
      redirect_to posts_path, alert: t("posts.controller.unauthorized")
    end
  end

  def require_login
    unless user_signed_in?
      Rails.logger.error(t("posts.controller.unauthenticated_access_log"))
      redirect_to login_path, alert: t("posts.controller.login_required")
    end
  end
end

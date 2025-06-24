class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [ :edit, :update, :reply ]
  before_action :require_login

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: t("comments.controller.created")
    else
      Rails.logger.error(t("comments.controller.create_error_log", errors: @comment.errors.full_messages.join(", ")))
      flash.now[:alert] = t("comments.controller.create_error")
      @comments = @post.comments.order(created_at: :desc)
      render "posts/show", status: :unprocessable_entity
    end
  end

  def reply
    @reply = @comment.replies.build(comment_params)
    @reply.user = current_user
    @reply.post = @post

    if @reply.save
      redirect_to @post, notice: t("comments.controller.reply_created")
    else
      Rails.logger.error(t("comments.controller.reply_error_log", errors: @reply.errors.full_messages.join(", ")))
      flash.now[:alert] = t("comments.controller.reply_error")
      @comments = @post.comments.order(created_at: :desc)
      @reply_with_errors = @reply
      render "posts/show", status: :unprocessable_entity
    end
  end

  def edit
    authorize_comment_owner
  end

  def update
    authorize_comment_owner

    if @comment.update(comment_params)
      redirect_to @post, notice: t("comments.controller.updated")
    else
      Rails.logger.error(t("comments.controller.update_error_log", errors: @comment.errors.full_messages.join(", ")))
      flash.now[:alert] = t("comments.controller.update_error")
      render :edit, status: :unprocessable_entity
    end
  end

  def admin_destroy_comment
    @comment = @post.comments.find(params[:id])

    unless can?(:admin_destroy_comment, @comment)
      flash[:alert] = t("comments.controller.unauthorized")
      redirect_to @post and return
    end

    if @comment.update(deleted_by_admin: true)
      @comment.user.check_for_ban!(self)
      redirect_to @post, notice: t("comments.controller.admin_deleted")
    else
      Rails.logger.error(t("comments.controller.admin_delete_error_log", errors: @comment.errors.full_messages.join(", ")))
      redirect_to @post, alert: t("comments.controller.admin_delete_error")
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
    params.require(:comment).permit(:content, :parent_id)
  end


  def authorize_comment_owner
    unless @comment.user == current_user
      Rails.logger.error(t("comments.controller.unauthorized"))
      redirect_to @post, alert: t("comments.controller.unauthorized")
    end
  end

  def require_login
    unless user_signed_in?
      Rails.logger.error(t("comments.controller.login_required"))
      redirect_to login_path, alert: t("comments.controller.login_required")
    end
  end
end

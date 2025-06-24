class CommentReactionsController < ApplicationController
  before_action :require_login
  before_action :set_comment

  def create
    reaction = current_user.comment_reactions.new(comment: @comment)

    if reaction.save
      redirect_to @comment.post, notice: t("comment_reactions.liked")
    else
      Rails.logger.error(t("comment_reactions.already_liked_log"))
      redirect_to @comment.post, alert: t("comment_reactions.already_liked")
    end
  end

  def destroy
    reaction = current_user.comment_reactions.find_by(comment: @comment)
    if reaction
      reaction.destroy
      redirect_to @comment.post, notice: t("comment_reactions.unliked")
    else
      Rails.logger.error(t("comment_reactions.not_liked_log"))
      redirect_to @comment.post, alert: t("comment_reactions.not_liked")
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def require_login
    unless user_signed_in?
      Rails.logger.error(t("comment_reactions.login_required_log"))
      redirect_to login_path, alert: t("comment_reactions.login_required")
    end
  end
end

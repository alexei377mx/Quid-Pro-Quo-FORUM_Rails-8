class CommentReactionsController < ApplicationController
  before_action :require_login
  before_action :set_comment

  def create
    reaction = current_user.comment_reactions.new(comment: @comment)

    if reaction.save
      redirect_to @comment.post, notice: "Te gustó el comentario."
    else
      Rails.logger.error("Ya le diste like a este comentario.")
      redirect_to @comment.post, alert: "Ya le diste like a este comentario."
    end
  end

  def destroy
    reaction = current_user.comment_reactions.find_by(comment: @comment)
    if reaction
      reaction.destroy
      redirect_to @comment.post, notice: "Quitaste tu reacción."
    else
      Rails.logger.error("No habías reaccionado a este comentario.")
      redirect_to @comment.post, alert: "No habías reaccionado a este comentario."
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def require_login
    unless user_signed_in?
      Rails.logger.error("Debes iniciar sesión para realizar esta acción.")
      redirect_to login_path, alert: "Debes iniciar sesión para realizar esta acción."
    end
  end
end

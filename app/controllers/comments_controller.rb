class CommentsController < ApplicationController
  before_action :set_post
  before_action :set_comment, only: [ :edit, :update, :reply ]
  before_action :require_login

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to @post, notice: "El comentario fue publicado exitosamente."
    else
      redirect_to @post, alert: "Hubo un error al publicar el comentario: #{@comment.errors.full_messages.join(', ')}"
    end
  end

  def reply
    @reply = @comment.replies.build(comment_params)
    @reply.user = current_user
    @reply.post = @post

    if @reply.save
      redirect_to @post, notice: "La respuesta fue publicada exitosamente."
    else
      redirect_to @post, alert: "Hubo un error al publicar la respuesta: #{@comment.errors.full_messages.join(', ')}"
    end
  end

  def edit
    authorize_comment_owner
  end

  def update
    authorize_comment_owner

    if @comment.update(comment_params)
      redirect_to @post, notice: "El comentario fue actualizado exitosamente."
    else
      Rails.logger.error("Error al actualizar comentario: #{@comment.errors.full_messages.join(', ')}")
      flash.now[:alert] = "Hubo un error al actualizar el comentario: #{@comment.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
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
      redirect_to @post, alert: "No estás autorizado para realizar esta acción."
    end
  end

  def require_login
    unless user_signed_in?
      redirect_to login_path, alert: "Debes iniciar sesión para realizar esta acción."
    end
  end
end

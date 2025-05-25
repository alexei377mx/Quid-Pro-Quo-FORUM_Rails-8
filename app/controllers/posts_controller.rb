class PostsController < ApplicationController
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_post_owner, only: [ :edit, :update, :destroy ]
  before_action :require_login, except: [ :index, :show ]

  def index
    @posts = Post.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @post = current_user.posts.new
  end

  def create
    @post = current_user.posts.new(post_params)

    if @post.save
      redirect_to @post, notice: "La publicación fue creada exitosamente."
    else
      Rails.logger.error("La creación de la publicación falló. Errores: #{@post.errors.full_messages.join(', ')}")
      flash.now[:alert] = "La creación de la publicación falló."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize_post_owner
  end

  def update
    authorize_post_owner

    if @post.update(post_params)
      redirect_to @post, notice: "La publicación fue actualizada exitosamente."
    else
      Rails.logger.error("La actualización de la publicación falló. Errores: #{@post.errors.full_messages.join(', ')}")
      flash.now[:alert] = "La actualización de la publicación falló."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @post.destroy
      redirect_to posts_url, notice: "La publicación fue eliminada exitosamente."
    else
      Rails.logger.error("No se pudo eliminar la publicación ID: #{@post.id}. Errores: #{@post.errors.full_messages.join(', ')}")
      redirect_to @post, alert: "No se pudo eliminar la publicación ID: #{@post.id}. Errores: #{@post.errors.full_messages.join(', ')}", status: :unprocessable_entity
    end
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end

  def authorize_post_owner
    unless @post.user == current_user
      Rails.logger.error("Intento no autorizado de modificar publicación ID: #{@post.id} por el usuario ID: #{current_user&.id}")
      redirect_to posts_path, alert: "No estás autorizado para realizar esta acción." and return
    end
  end

  def require_login
    unless user_signed_in?
      Rails.logger.error("Intento de acceso no autenticado a recurso protegido")
      redirect_to login_path, alert: "Debes iniciar sesión para realizar esta acción."
    end
  end
end

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
      redirect_to posts_path, alert: "Esta publicación fue eliminada por la administración." and return
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
    @category = params[:category_id].capitalize

    if Post::CATEGORIES.include?(@category)
      @posts = Post.where(category: @category, deleted_by_admin: false).order(created_at: :desc).page(params[:page]).per(10)
    else
      @posts = []
      flash[:alert] = "La categoría seleccionada no es válida."
    end
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
    if @post.deleted_by_admin
      redirect_to posts_path, alert: "Esta publicación fue eliminada por la administración." and return
    end
  end

  def update
    if @post.deleted_by_admin
      redirect_to posts_path, alert: "Esta publicación fue eliminada por la administración." and return
    end

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

  def admin_destroy_post
    authorize! :admin_destroy_post, @post

    if @post.update_column(:deleted_by_admin, true)
      @post.user.check_for_ban!(self)
      redirect_to posts_path, alert: "Publicación eliminada por administración."
    else
      Rails.logger.error("No se pudo eliminar la publicación como administrador: #{@post.id}. Errores: #{@post.errors.full_messages.join(', ')}")
      redirect_to @post, alert: "No se pudo eliminar la publicación como administrador."
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

class PostsController < ApplicationController
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_post_owner, only: [ :edit, :update, :destroy ]
  before_action :require_login, except: [ :index, :show ]

  def index
    logger.info "Listando todas las publicaciones"
    @posts = Post.all.order(created_at: :desc)
  end

  def show
    logger.info "Mostrando publicación ID: #{@post.id}"
  end

  def new
    logger.info "Formulario de nueva publicación solicitado por el usuario ID: #{current_user.id}"
    @post = current_user.posts.new
  end

  def create
    logger.info "Intentando crear publicación por el usuario ID: #{current_user.id}"
    @post = current_user.posts.new(post_params)

    if @post.save
      logger.info "Publicación creada exitosamente. ID: #{@post.id}"
      redirect_to @post, notice: "La publicación fue creada exitosamente."
    else
      logger.warn "La creación de la publicación falló. Errores: #{@post.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    logger.info "Formulario de edición solicitado para publicación ID: #{@post.id}"
    authorize_post_owner
  end

  def update
    logger.info "Intentando actualizar publicación ID: #{@post.id}"
    authorize_post_owner

    if @post.update(post_params)
      logger.info "Publicación actualizada exitosamente. ID: #{@post.id}"
      redirect_to @post, notice: "La publicación fue actualizada exitosamente."
    else
      logger.warn "La actualización de la publicación falló. Errores: #{@post.errors.full_messages.join(', ')}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    logger.info "Intentando eliminar publicación ID: #{@post.id}"

    if @post.destroy
      logger.info "Publicación eliminada exitosamente. ID: #{@post.id}"
      redirect_to posts_url, notice: "La publicación fue eliminada exitosamente."
    else
      logger.error "Falló la eliminación de la publicación ID: #{@post.id}. Errores: #{@post.errors.full_messages.join(', ')}"
      redirect_to @post, alert: "No se pudo eliminar la publicación.", status: :unprocessable_entity
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
      logger.warn "Intento no autorizado de modificar publicación ID: #{@post.id} por el usuario ID: #{current_user&.id}"
      redirect_to posts_path, alert: "No estás autorizado para realizar esta acción." and return
    end
  end

  def require_login
    unless user_signed_in?
      logger.warn "Intento de acceso no autenticado a recurso protegido"
      redirect_to login_path, alert: "Debes iniciar sesión para realizar esta acción."
    end
  end
end

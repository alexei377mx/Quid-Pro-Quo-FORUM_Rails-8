class UsersController < ApplicationController
  before_action :authenticate_user!, only: [ :show, :edit_password, :update_password ]

  def show
    @user = current_user
    @posts = @user.posts.order(created_at: :desc).page(params[:page]).per(10)
  end

  def new
    @user = User.new
    @show_checkbox_recaptcha = false
  end

  def create
    @user = User.new(user_params)

    if @user.valid?
      v3_valid = verify_recaptcha(
        model: @user,
        action: "registration",
        minimum_score: 0.5,
        secret_key: Rails.application.credentials.dig(:recaptcha, :secret_key_v3)
      )

      v2_valid = verify_recaptcha(model: @user, secret_key: Rails.application.credentials.dig(:recaptcha, :secret_key_v2)) unless v3_valid

      if v3_valid || v2_valid
        @user.save
        session[:user_id] = @user.id
        redirect_to root_path, notice: t("users.controller.registration_success")
        Rails.logger.info("Nuevo usuario registrado: #{@user.username}")
      else
        @show_checkbox_recaptcha = true
        flash.now[:alert] = t("users.controller.recaptcha_failed")
        Rails.logger.error("Falló reCAPTCHA v3 y v2 en registro")
        render :new, status: :unprocessable_entity
      end
    else
      Rails.logger.warn("Error al registrar usuario: #{@user.username} - Errores: #{@user.errors.full_messages.join(', ')}")
      flash.now[:alert] = t("users.controller.registration_failed")
      render :new, status: :unprocessable_entity
    end
  end

  def edit_password
    @user = current_user
  end

  def update_password
    @user = current_user

    unless @user.authenticate(params[:user][:current_password])
      flash.now[:alert] = t("users.controller.incorrect_current_password")
      render :edit_password, status: :unprocessable_entity
      return
    end

    if params[:user][:password] != params[:user][:password_confirmation]
      flash.now[:alert] = t("users.controller.passwords_do_not_match")
      render :edit_password, status: :unprocessable_entity
      return
    end

    if @user.update(password_params)
      redirect_to profile_path, notice: t("users.controller.password_updated")
    else
      Rails.logger.error "Error al actualizar la contraseña para el usuario ID=#{@user.id}: #{@user.errors.full_messages.join(', ')}"
      flash.now[:alert] = t("users.controller.password_update_failed")
      render :edit_password, status: :unprocessable_entity
    end
  end

  def avatar
    @user = current_user
    if @user.update(user_params)
      redirect_to profile_path, notice: t("users.controller.avatar_updated")
    else
      Rails.logger.error "Error al actualizar el avatar usuario ID=#{@user.id}: #{@user.errors.full_messages.join(', ')}"
      flash.now[:alert] = t("users.controller.avatar_update_failed", errors: @user.errors.full_messages.join(", "))
      @user.reload
      @posts = @user.posts.order(created_at: :desc).page(params[:page]).per(10)
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :username, :email, :password, :password_confirmation, :avatar)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def authenticate_user!
    unless user_signed_in?
      flash[:alert] = t("users.controller.login_required")
      redirect_to login_path
    end
  end
end

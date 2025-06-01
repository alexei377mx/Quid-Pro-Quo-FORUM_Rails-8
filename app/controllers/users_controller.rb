class UsersController < ApplicationController
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
        redirect_to root_path, notice: "Registrado correctamente"
        Rails.logger.info("Nuevo usuario registrado: #{@user.username}")
      else
        @show_checkbox_recaptcha = true
        flash.now[:alert] = "No pudimos verificar que eres humano."
        Rails.logger.error("Falló reCAPTCHA v3 y v2 en registro")
        render :new, status: :unprocessable_entity
      end
    else
      Rails.logger.warn("Error al registrar usuario: #{@user.username} - Errores: #{@user.errors.full_messages.join(', ')}")
      flash.now[:alert] = "Error al registrar usuario"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :username, :email, :password, :password_confirmation)
  end
end

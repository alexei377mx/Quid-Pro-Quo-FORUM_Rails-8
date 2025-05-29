class SessionsController < ApplicationController
  def new
    @show_checkbox_recaptcha = false
  end

  def create
    errors = []
    errors << "El campo email o nombre de usuario no puede estar vacío." if params[:login].blank?
    errors << "El campo contraseña no puede estar vacío." if params[:password].blank?

    if errors.any?
      flash.now[:alert] = errors.join(" ")
      return render :new, status: :unprocessable_entity
    end

     user = User.where("email = :login OR name = :login OR username = :login", login: params[:login]).first

    if user.nil?
      flash.now[:alert] = "No se encontró un usuario con ese email o nombre de usuario."
      Rails.logger.warn("Intento de login fallido - usuario no encontrado: #{params[:login]}")
      return render :new, status: :unprocessable_entity
    end

    unless user.authenticate(params[:password])
      flash.now[:alert] = "Contraseña incorrecta."
      Rails.logger.warn("Intento de login fallido - contraseña incorrecta para: #{user.username}")
      return render :new, status: :unprocessable_entity
    end

    v3_success = verify_recaptcha(
      action: "login",
      minimum_score: 0.5,
      secret_key: Rails.application.credentials.dig(:recaptcha, :secret_key_v3)
    )

    v2_success = verify_recaptcha(
      secret_key: Rails.application.credentials.dig(:recaptcha, :secret_key_v2)
    ) unless v3_success

    if v3_success || v2_success
      session[:user_id] = user.id
      redirect_to root_path, notice: "Has iniciado sesión exitosamente."
    else
      @show_checkbox_recaptcha = true
      flash.now[:alert] = "No pudimos verificar que eres humano."
      Rails.logger.warn("Falló reCAPTCHA v3 y v2")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Has cerrado sesión."
  end
end

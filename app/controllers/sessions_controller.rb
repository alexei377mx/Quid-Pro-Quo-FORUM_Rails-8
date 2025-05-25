class SessionsController < ApplicationController
  def new
    logger.info "Acceso a la página de inicio de sesión"
  end

  def create
    if verify_recaptcha
      user = User.find_by("email = ? OR name = ?", params[:login], params[:login])

      if user&.authenticate(params[:password])
        session[:user_id] = user.id
        redirect_to root_path, notice: "Has iniciado sesión exitosamente."
      else
        flash.now[:alert] = "Credenciales incorrectas."
        render :new, status: :unprocessable_entity
      end
    else
      flash.now[:alert] = "Por favor completa el reCAPTCHA"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if session[:user_id]
      logger.info "Cierre de sesión para el usuario ID: #{session[:user_id]}"
      session[:user_id] = nil
      redirect_to root_path, notice: "Has cerrado sesión."
    else
      logger.warn "Intento de cierre de sesión sin sesión activa"
      redirect_to root_path, alert: "No había sesión activa."
    end
  end
end

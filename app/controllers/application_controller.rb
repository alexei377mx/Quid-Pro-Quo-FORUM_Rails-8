class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :user_signed_in?

  after_action :log_action
  before_action :reject_banned_user

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def user_signed_in?
    current_user.present?
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, alert: "No estás autorizado para acceder a esta página."
  end

  def log_action
    return unless user_signed_in?

    Log.create(
      user: current_user,
      action: "#{controller_name}##{action_name}",
      description: "Params: #{request.filtered_parameters.except(:password, :password_confirmation).inspect}, IP: #{request.remote_ip}"
    )
  rescue => e
    Rails.logger.error("Error al guardar log: #{e.message}")
  end

  def reject_banned_user
    if current_user&.banned?
      reset_session
      redirect_to root_path, alert: "Tu cuenta ha sido baneada."
    end
  end
end

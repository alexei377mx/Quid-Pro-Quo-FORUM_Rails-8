class ReportsController < ApplicationController
  before_action :require_login
  load_and_authorize_resource only: [ :index ]

  def new
    @reportable = find_reportable
    @report = Report.new
  end

  def create
    @reportable = find_reportable
    @report = @reportable.reports.build(report_params.merge(user: current_user))

    if @report.save
      redirect_to @reportable.is_a?(Post) ? post_path(@reportable) : post_path(@reportable.post),
                  notice: "El reporte fue enviado correctamente."
    else
      flash.now[:alert] = "No se pudo enviar el reporte."
      render :new, status: :unprocessable_entity
    end
  end

  def index
    @reports = Report.includes(:user, :reportable).order(created_at: :desc)
  end

  private

  def report_params
    params.require(:report).permit(:reason)
  end

  def find_reportable
    if params[:post_id]
      Post.find(params[:post_id])
    elsif params[:comment_id]
      Comment.find(params[:comment_id])
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  def require_login
    unless user_signed_in?
      Rails.logger.error("Intento de acceso no autenticado a recurso protegido")
      redirect_to login_path, alert: "Debes iniciar sesión para realizar esta acción."
    end
  end
end

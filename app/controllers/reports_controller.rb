class ReportsController < ApplicationController
  before_action :require_login

  def new
    @reportable = find_reportable
    @report = Report.new
  end

  def create
    @reportable = find_reportable
    @report = @reportable.reports.build(report_params.merge(user: current_user))

    if @report.save
      redirect_to @reportable.is_a?(Post) ? post_path(@reportable) : post_path(@reportable.post),
                  notice: t("reports.controller.created")
    else
      flash.now[:alert] = t("reports.controller.create_failed")
      render :new, status: :unprocessable_entity
    end
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
      redirect_to login_path, alert: t("reports.controller.auth_required")
    end
  end
end

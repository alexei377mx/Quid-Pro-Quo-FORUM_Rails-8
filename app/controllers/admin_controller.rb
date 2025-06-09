class AdminController < ApplicationController
  before_action -> { authorize! :admin, :all }

  def dashboard
    @tab = params[:tab] || "reports"

    case @tab
    when "reports"
      @reports = Report.includes(:user, :reportable)
                       .without_deleted_content
                       .order(created_at: :desc)

      if params[:type].present?
        @reports = @reports.where(reportable_type: params[:type])
      end

      if params.key?(:reviewed) && %w[true false].include?(params[:reviewed])
        reviewed = params[:reviewed] == "true"
        @reports = @reports.where(reviewed: reviewed)
      elsif !params.key?(:reviewed)
        @reports = @reports.where(reviewed: false)
        params[:reviewed] = "false"
      end

      if params[:from].present? && params[:to].present?
        from = Date.parse(params[:from]) rescue nil
        to = Date.parse(params[:to]) rescue nil
        if from && to
          @reports = @reports.where(created_at: from.beginning_of_day..to.end_of_day)
        end
      end

      @reports = @reports.page(params[:page]).per(20)

    when "radios"
      @radios = Radio.order(:title)
      @radio = Radio.new

    when "logs"
      @logs = Log.includes(:user)
                 .order(created_at: :desc)
                 .page(params[:page])
                 .per(20)
    end
  end

  def toggle_report_reviewed
    @report = Report.find(params[:id])
    @report.update(reviewed: !@report.reviewed)

    redirect_to admin_path(
      tab: "reports",
      type: params[:type],
      reviewed: params[:reviewed],
      from: params[:from],
      to: params[:to],
      page: params[:page]
    ), notice: "Estado del reporte actualizado."
  end
end

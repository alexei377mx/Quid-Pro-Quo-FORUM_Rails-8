class AdminController < ApplicationController
  before_action -> { authorize! :admin, :all }

  def dashboard
    @tab = params[:tab] || "reports"

    case @tab
    when "reports"
      from = parse_date(params[:from])
      to = parse_date(params[:to])
      reviewed = to_boolean(params[:reviewed])

      @reports = Report.includes(:user, :reportable)
                      .without_deleted_content
                      .order(created_at: :desc)
                      .by_type(params[:type])
                      .by_reviewed(reviewed)
                      .by_date_range(from, to)
                      .page(params[:page])
                      .per(20)
      params[:reviewed] ||= "false"

    when "radios"
      @radios = Radio.order(:title)
      @radio = Radio.new

    when "logs"
      @logs = Log.includes(:user)
                .order(created_at: :desc)
                .page(params[:page])
                .per(20)

    when "contact_messages"
      from = parse_date(params[:from])
      to = parse_date(params[:to])
      reviewed = to_boolean(params[:reviewed])

      @contact_messages = ContactMessage.order(created_at: :desc)
                                        .by_reviewed(reviewed)
                                        .by_date_range(from, to)
                                        .page(params[:page])
                                        .per(20)
      params[:reviewed] ||= "false"
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
    ), notice: t("admin.controller.report_status_updated")
  end

  def toggle_contact_message_reviewed
    @contact_message = ContactMessage.find(params[:id])
    @contact_message.update(reviewed: !@contact_message.reviewed)

    redirect_to admin_path(
      tab: "contact_messages",
      reviewed: params[:reviewed],
      from: params[:from],
      to: params[:to],
      page: params[:page]
    ), notice: t("admin.controller.contact_message_status_updated")
  end

  private

  def parse_date(date_string)
    Date.parse(date_string) rescue nil
  end

  def to_boolean(value)
    return true if value == "true"
    return false if value == "false"
    nil
  end
end

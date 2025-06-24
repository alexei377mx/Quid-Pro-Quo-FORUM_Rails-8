require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
    @post = posts(:one)
    @comment = comments(:one)
  end

  test "should show new form for post when logged in" do
    log_in_as(@admin)
    get new_post_report_path(@post, locale: I18n.locale)
    assert_response :success
    assert_select "form"
  end

  test "should show new form for comment when logged in" do
    log_in_as(@admin)
    get new_comment_report_path(@comment, locale: I18n.locale)
    assert_response :success
    assert_select "form"
  end

  test "should create report for post with valid reason (ID)" do
    log_in_as(@admin)
    valid_reason_id = Report::REASONS.keys.first.to_s
    assert_difference("Report.count", 1) do
      post post_reports_path(@post, locale: I18n.locale), params: { report: { reason: valid_reason_id } }
    end
    assert_redirected_to post_path(@post, locale: I18n.locale)
    assert_equal I18n.t("reports.controller.created"), flash[:notice]
  end

  test "should not create report with invalid reason" do
    log_in_as(@admin)
    assert_no_difference("Report.count") do
      post post_reports_path(@post, locale: I18n.locale), params: { report: { reason: "999" } }
    end
    assert_response :unprocessable_entity
    assert_equal I18n.t("reports.controller.create_failed"), flash[:alert]
  end

  test "should redirect to login when trying to access new report form while unauthenticated" do
    get new_post_report_path(@post, locale: I18n.locale)
    assert_redirected_to login_path(locale: I18n.locale)
    follow_redirect!
    assert_equal I18n.t("reports.controller.auth_required"), flash[:alert]
  end

  test "should redirect to login when trying to create report while unauthenticated" do
    valid_reason_id = Report::REASONS.keys.first.to_s
    post post_reports_path(@post, locale: I18n.locale), params: { report: { reason: valid_reason_id } }
    assert_redirected_to login_path(locale: I18n.locale)
    follow_redirect!
    assert_equal I18n.t("reports.controller.auth_required"), flash[:alert]
  end

  test "admin should access reports index from admin panel" do
    log_in_as(@admin)
    get admin_path(tab: "reports", locale: I18n.locale)
    assert_response :success
  end

  test "non-admin user should not access reports index" do
    log_in_as(@user)
    get admin_path(tab: "reports", locale: I18n.locale)
    assert_redirected_to root_path(locale: I18n.locale)
    follow_redirect!
    assert_equal I18n.t("errors.not_authorized"), flash[:alert]
  end

  test "unauthenticated user should be redirected from reports index" do
    get admin_path(tab: "reports", locale: I18n.locale)
    assert_redirected_to root_path(locale: I18n.locale)
    follow_redirect!
    assert_equal I18n.t("errors.not_authorized"), flash[:alert]
  end
end

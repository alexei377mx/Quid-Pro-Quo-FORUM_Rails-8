require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
    @post = posts(:one)
    @comment = comments(:one)
  end

  test "should get new for post when logged in" do
    log_in_as(@admin)
    get new_post_report_path(@post)
    assert_response :success
    assert_select "form"
  end

  test "should get new for comment when logged in" do
    log_in_as(@admin)
    get new_comment_report_path(@comment)
    assert_response :success
    assert_select "form"
  end

  test "should create report for post with valid reason" do
    log_in_as(@admin)
    assert_difference("Report.count", 1) do
      post post_reports_path(@post), params: { report: { reason: Report::REASONS.first } }
    end
    assert_redirected_to post_path(@post)
  end

  test "should not create report with invalid reason" do
    log_in_as(@admin)
    assert_no_difference("Report.count") do
      post post_reports_path(@post), params: { report: { reason: "Motivo inválido" } }
    end
    assert_response :unprocessable_entity
  end

  test "should redirect new report if not logged in" do
    get new_post_report_path(@post)
    assert_redirected_to login_path
    follow_redirect!
    assert_match "Debes iniciar sesión", response.body
  end

  test "should redirect create report if not logged in" do
    post post_reports_path(@post), params: { report: { reason: Report::REASONS.first } }
    assert_redirected_to login_path
  end

  test "admin should access report index" do
    log_in_as(@admin)
    get reports_path
    assert_response :success
    assert_select "h1", /Reportes de usuarios/i
  end

  test "non-admin should not access report index" do
    log_in_as(@user, password: "secret456")
    get reports_path
    assert_redirected_to root_path
    follow_redirect!
    assert_match "no estás autorizado", response.body.downcase
  end

  test "unauthenticated user should be redirected from report index" do
    get reports_path
    assert_redirected_to login_path
    follow_redirect!
    assert_match "debes iniciar sesión", response.body.downcase
  end
end

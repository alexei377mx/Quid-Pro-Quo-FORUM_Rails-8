require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:one)
    @comment = comments(:one)
  end

  test "should get new for post when logged in" do
    log_in_as(@user)
    get new_post_report_path(@post)
    assert_response :success
    assert_select "form"
  end

  test "should get new for comment when logged in" do
    log_in_as(@user)
    get new_comment_report_path(@comment)
    assert_response :success
    assert_select "form"
  end

  test "should create report for post with valid reason" do
    log_in_as(@user)
    assert_difference("Report.count", 1) do
      post post_reports_path(@post), params: { report: { reason: Report::REASONS.first } }
    end
    assert_redirected_to post_path(@post)
  end

  test "should not create report with invalid reason" do
    log_in_as(@user)
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
end

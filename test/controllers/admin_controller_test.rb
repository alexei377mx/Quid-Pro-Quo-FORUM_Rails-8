require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:one)
    @user = users(:two)
  end

  test "should access admin panel as admin" do
    log_in_as(@admin)
    get admin_path
    assert_response :success
  end

  test "should redirect to root when not logged in" do
    get admin_path
    assert_redirected_to root_url(locale: I18n.locale)
  end

  test "should deny access to admin panel for non-admin users" do
    log_in_as(@user)
    get admin_path
    assert_redirected_to root_url(locale: I18n.locale)
    assert_equal I18n.t("errors.not_authorized"), flash[:alert]
  end
end

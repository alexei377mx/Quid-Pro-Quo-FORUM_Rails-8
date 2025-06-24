require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "should get login page" do
    get login_path(locale: I18n.locale)
    assert_response :success
  end

  test "should login with correct credentials (email)" do
    post login_path(locale: I18n.locale), params: { login: @user.email, password: "NewPassword1!" }
    assert_redirected_to root_path(locale: I18n.locale)
    assert_equal @user.id, session[:user_id]
    assert_equal I18n.t("sessions.controller.login_success"), flash[:notice]
  end

  test "should login with correct credentials (username)" do
    post login_path(locale: I18n.locale), params: { login: @user.name, password: "NewPassword1!" }
    assert_redirected_to root_path(locale: I18n.locale)
    assert_equal @user.id, session[:user_id]
    assert_equal I18n.t("sessions.controller.login_success"), flash[:notice]
  end

  test "should not login with wrong password" do
    post login_path(locale: I18n.locale), params: { login: @user.email, password: "wrongpass" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_equal I18n.t("sessions.controller.invalid_password"), flash[:alert]
  end

  test "should not login with non-existent user" do
    post login_path(locale: I18n.locale), params: { login: "nonexistent@example.com", password: "whatever" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_equal I18n.t("sessions.controller.user_not_found"), flash[:alert]
  end

  test "should not login with empty fields" do
    post login_path(locale: I18n.locale), params: { login: "", password: "?" }
    assert_response :unprocessable_entity
    assert_equal I18n.t("sessions.controller.blank_login"), flash[:alert]
  end

  test "should logout successfully" do
    post login_path(locale: I18n.locale), params: { login: @user.email, password: "NewPassword1!" }
    assert_equal @user.id, session[:user_id]

    delete logout_path(locale: I18n.locale)
    assert_redirected_to root_path(locale: I18n.locale)
    assert_nil session[:user_id]
    assert_equal I18n.t("sessions.controller.logout_success"), flash[:notice]
  end

  test "should redirect if user is banned" do
    @banned_user = users(:banned_user)

    post login_path(locale: I18n.locale), params: { login: @banned_user.email, password: "NewPassword1!" }
    assert_equal @banned_user.id, session[:user_id]

    get root_path(locale: I18n.locale)

    assert_redirected_to root_path(locale: I18n.locale)
    assert_nil session[:user_id]
    assert_equal I18n.t("errors.account_banned"), flash[:alert]
  end
end

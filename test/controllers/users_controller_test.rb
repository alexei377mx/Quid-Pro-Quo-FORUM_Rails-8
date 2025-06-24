require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should display registration form" do
    get register_path(locale: I18n.locale)
    assert_response :success
    assert_select "form"
  end

  test "should register user with valid data and valid recaptcha" do
    assert_difference("User.count", 1) do
      post users_path(locale: I18n.locale), params: {
        user: {
          name: "Carlos Ruiz",
          username: "carlitos",
          email: "carlos@example.com",
          password: "NewPassword1!",
          password_confirmation: "NewPassword1!"
        }
      }
    end

    assert_redirected_to root_path(locale: I18n.locale)
    assert_equal I18n.t("users.controller.registration_success"), flash[:notice]
  end

  test "should not register user with invalid data" do
    assert_no_difference("User.count") do
      post users_path(locale: I18n.locale), params: {
        user: {
          name: "",
          username: "",
          email: "notanemail",
          password: "123",
          password_confirmation: "456"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_equal I18n.t("users.controller.registration_failed"), flash[:alert]
  end

  test "requires login to edit password" do
    get edit_password_path(locale: I18n.locale)
    assert_redirected_to login_path(locale: I18n.locale)
    assert_equal I18n.t("users.controller.login_required"), flash[:alert]
  end

  test "displays password change form when logged in" do
    log_in_as(@user)
    get edit_password_path(locale: I18n.locale)
    assert_response :success
    assert_select "form"
  end

  test "updates password successfully with valid data" do
    log_in_as(@user)
    patch update_password_path(locale: I18n.locale), params: {
      user: {
        current_password: "NewPassword1!",
        password: "NewPassword1!",
        password_confirmation: "NewPassword1!"
      }
    }
    assert_redirected_to profile_path(locale: I18n.locale)
    assert_equal I18n.t("users.controller.password_updated"), flash[:notice]
    @user.reload
    assert @user.authenticate("NewPassword1!")
  end

  test "does not update password with incorrect current password" do
    log_in_as(@user)
    patch update_password_path(locale: I18n.locale), params: {
      user: {
        current_password: "wrongpassword",
        password: "NewPassword1!",
        password_confirmation: "NewPassword1!"
      }
    }
    assert_response :unprocessable_entity
    assert_equal I18n.t("users.controller.incorrect_current_password"), flash[:alert]
  end

  test "does not update password when new passwords don't match" do
    log_in_as(@user)
    patch update_password_path(locale: I18n.locale), params: {
      user: {
        current_password: "NewPassword1!",
        password: "NewPassword1!",
        password_confirmation: "Different1!"
      }
    }
    assert_response :unprocessable_entity
    assert_equal I18n.t("users.controller.passwords_do_not_match"), flash[:alert]
  end

  test "updates avatar successfully" do
    log_in_as(@user)
    avatar_file = fixture_file_upload("user.jpeg", "image/jpeg")

    patch user_avatar_path(locale: I18n.locale), params: {
      user: { avatar: avatar_file }
    }

    assert_redirected_to profile_path(locale: I18n.locale)
    assert_equal I18n.t("users.controller.avatar_updated"), flash[:notice]
    @user.reload
    assert @user.avatar.attached?
  end

  test "does not update avatar with invalid file" do
    log_in_as(@user)
    invalid_file = fixture_file_upload("invalid_file.pdf", "application/pdf")

    patch user_avatar_path(locale: I18n.locale), params: {
      user: { avatar: invalid_file }
    }

    assert_response :unprocessable_entity
  end
end

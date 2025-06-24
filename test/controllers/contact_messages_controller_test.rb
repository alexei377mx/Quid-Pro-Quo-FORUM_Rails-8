require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact_message = contact_messages(:one)
    @admin = users(:one)
    @user = users(:two)
  end

  test "should display contact form" do
    get contact_url
    assert_response :success
    assert_select "form"
  end

  test "should create contact message with valid parameters" do
    assert_difference("ContactMessage.count", 1) do
      post contact_messages_url, params: {
        contact_message: {
          name: "Test Name",
          email: "test@example.com",
          subject: "Test subject",
          message: "This is a test message"
        }
      }
    end

    assert_redirected_to root_url(locale: I18n.locale)
    assert_equal I18n.t("contact_messages.controller.success"), flash[:notice]
  end

  test "should not create contact message with invalid parameters" do
    post contact_messages_url, params: {
      contact_message: {
        name: "",
        email: "test@example.com",
        subject: "Test subject",
        message: "This is a test message"
      }
    }

    assert_response :unprocessable_entity
    assert_select "form"
    assert_equal I18n.t("contact_messages.controller.failure"), flash[:alert]
  end

  test "should show contact message when authorized" do
    log_in_as(@admin)
    get contact_message_url(@contact_message)
    assert_response :success
    assert_match @contact_message.subject, @response.body
  end

  test "should redirect when not authorized to view contact message" do
    log_in_as(@user)

    get contact_message_url(@contact_message)
    assert_redirected_to root_url(locale: I18n.locale)
    assert_equal I18n.t("errors.not_authorized"), flash[:alert]
  end
end

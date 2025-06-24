require "test_helper"

class RadiosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
    @radio = radios(:one)
  end

  test "admin should get index" do
    log_in_as(@admin)
    get admin_url(locale: I18n.locale, tab: "radios")
    assert_response :success
  end

  test "admin should create radio with valid data" do
    log_in_as(@admin)
    assert_difference("Radio.count", 1) do
      post radios_url(locale: I18n.locale), params: {
        radio: { title: "New Radio", stream_url: "https://example.com/stream" }
      }
    end
    assert_redirected_to admin_url(locale: I18n.locale, tab: "radios")
    follow_redirect!
    assert_match I18n.t("radios.controller.created"), response.body
  end

  test "admin should delete radio" do
    log_in_as(@admin)
    assert_difference("Radio.count", -1) do
      delete radio_url(@radio, locale: I18n.locale)
    end
    assert_redirected_to admin_url(locale: I18n.locale, tab: "radios")
    follow_redirect!
    assert_match I18n.t("radios.controller.deleted"), response.body
  end

  test "user should not access index" do
    log_in_as(@user)
    get admin_url(locale: I18n.locale, tab: "radios")
    assert_redirected_to root_url(locale: I18n.locale)
    follow_redirect!
  end

  test "user should not create radio" do
    log_in_as(@user)
    assert_no_difference("Radio.count") do
      post radios_url(locale: I18n.locale), params: {
        radio: { title: "Unauthorized Radio", stream_url: "https://example.com/stream" }
      }
    end
    assert_redirected_to root_url(locale: I18n.locale)
    follow_redirect!
  end

  test "user should not delete radio" do
    log_in_as(@user)
    delete radio_url(@radio, locale: I18n.locale)
    assert_redirected_to root_url(locale: I18n.locale)
    follow_redirect!
  end

  test "guest should be redirected to login" do
    get admin_url(locale: I18n.locale, tab: "radios")
    assert_redirected_to root_url(locale: I18n.locale)
  end
end

require "test_helper"

class RadiosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
    @radio = radios(:one)
  end

  test "admin debería mostrar el índice" do
    log_in_as(@admin)
    get admin_path(tab: "radios")
    assert_response :success
  end

  test "admin debería crear una radio con datos válidos" do
    log_in_as(@admin)
    assert_difference("Radio.count", 1) do
      post radios_url, params: {
        radio: { title: "Nueva Radio", stream_url: "https://example.com/stream" }
      }
    end
    assert_redirected_to admin_path(tab: "radios")
    follow_redirect!
    assert_match "Radio añadida correctamente", response.body
  end

  test "admin debería eliminar una radio" do
    log_in_as(@admin)
    assert_difference("Radio.count", -1) do
      delete radio_url(@radio)
    end
    assert_redirected_to admin_path(tab: "radios")
    follow_redirect!
    assert_match "Radio eliminada correctamente", response.body
  end

  test "usuario no debería acceder al índice" do
    log_in_as(@user)
    get admin_path(tab: "radios")
    assert_redirected_to root_url
    follow_redirect!
  end

  test "usuario no debería crear radio" do
    log_in_as(@user)
    assert_no_difference("Radio.count") do
      post radios_url, params: {
        radio: { title: "Radio Prohibida", stream_url: "https://example.com/stream" }
      }
    end
    assert_redirected_to root_url
    follow_redirect!
  end

  test "usuario no debería eliminar radio" do
    log_in_as(@user)
    delete radio_url(@radio)
    assert_redirected_to root_url
    follow_redirect!
  end

  test "invitado es redirigido al login" do
    get admin_path(tab: "radios")
    assert_redirected_to root_url
  end
end

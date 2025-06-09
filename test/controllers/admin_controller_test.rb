require "test_helper"

class AdminControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:one)
    @user = users(:two)
  end

  test "debería acceder al panel como admin" do
    log_in_as(@admin)
    get admin_path
    assert_response :success
  end

  test "debería redirigir al panel cuando no está logueado" do
    get admin_path
    assert_redirected_to root_path
  end

  test "debería negar acceso al panel para usuarios que no son admin" do
    log_in_as(@user)
    get admin_path
    assert_redirected_to root_path
    assert_equal "No estás autorizado para acceder a esta página.", flash[:alert]
  end
end

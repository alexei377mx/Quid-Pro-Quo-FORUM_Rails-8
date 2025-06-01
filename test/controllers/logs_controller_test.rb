require "test_helper"

class LogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_user = users(:one)
    @regular_user = users(:two)
    @log = logs(:one)
  end

  test "debería permitir acceso al índice de logs para admin" do
    log_in_as(@admin_user)
    get logs_url
    assert_response :success
    assert_select "h1", "Logs de actividad"
    assert_match @log.action, response.body
  end

  test "no debería permitir acceso a usuarios normales" do
    log_in_as(@regular_user)
    get logs_url
    assert_redirected_to root_path
    assert_equal "No estás autorizado para acceder a esta página.", flash[:alert]
  end

  test "no debería permitir acceso sin iniciar sesión" do
    get logs_url
    assert_redirected_to root_path
    assert_equal "No estás autorizado para acceder a esta página.", flash[:alert]
  end
end

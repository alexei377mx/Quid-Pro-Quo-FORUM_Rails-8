require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:one)
    @user = users(:two)
    @post = posts(:one)
    @comment = comments(:one)
  end

  test "debería mostrar el formulario nuevo para post cuando está logueado" do
    log_in_as(@admin)
    get new_post_report_path(@post)
    assert_response :success
    assert_select "form"
  end

  test "debería mostrar el formulario nuevo para comentario cuando está logueado" do
    log_in_as(@admin)
    get new_comment_report_path(@comment)
    assert_response :success
    assert_select "form"
  end

  test "debería crear reporte para post con motivo válido" do
    log_in_as(@admin)
    assert_difference("Report.count", 1) do
      post post_reports_path(@post), params: { report: { reason: Report::REASONS.first } }
    end
    assert_redirected_to post_path(@post)
  end

  test "no debería crear reporte con motivo inválido" do
    log_in_as(@admin)
    assert_no_difference("Report.count") do
      post post_reports_path(@post), params: { report: { reason: "Motivo inválido" } }
    end
    assert_response :unprocessable_entity
  end

  test "debería redirigir al formulario nuevo de reporte si no está logueado" do
    get new_post_report_path(@post)
    assert_redirected_to login_path
    follow_redirect!
  end

  test "debería redirigir al crear reporte si no está logueado" do
    post post_reports_path(@post), params: { report: { reason: Report::REASONS.first } }
    assert_redirected_to login_path
  end

  test "admin debería acceder al índice de reportes desde el panel de administrador" do
    log_in_as(@admin)
    get admin_path(tab: "reports")
    assert_response :success
  end

  test "usuario no admin no debería acceder al índice de reportes" do
    log_in_as(@user)
    get admin_path(tab: "reports")
    assert_redirected_to root_path
    follow_redirect!
  end

  test "usuario no autenticado debería ser redirigido desde el índice de reportes" do
    get admin_path(tab: "reports")
    assert_redirected_to root_path
    follow_redirect!
  end
end

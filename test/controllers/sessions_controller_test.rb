require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "debería obtener la página de inicio de sesión" do
    get login_path
    assert_response :success
  end

  test "debería iniciar sesión con credenciales correctas (email)" do
    post login_path, params: { login: @user.email, password: "NewPassword1!" }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
  end

  test "debería iniciar sesión con credenciales correctas (name)" do
    post login_path, params: { login: @user.name, password: "NewPassword1!" }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
  end

  test "no debería iniciar sesión con contraseña incorrecta" do
    post login_path, params: { login: @user.email, password: "wrongpass" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "no debería iniciar sesión con un usuario no existente" do
    post login_path, params: { login: "nonexistent@example.com", password: "whatever" }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "no debería iniciar sesión con campos vacíos" do
    post login_path, params: { login: "", password: "" }
    assert_response :unprocessable_entity
  end

  test "debería cerrar sesión correctamente" do
    post login_path, params: { login: @user.email, password: "NewPassword1!" }
    assert_equal @user.id, session[:user_id]

    delete logout_path
    assert_redirected_to root_path
    assert_nil session[:user_id]
  end

  test "debería redirigir si el usuario está baneado" do
    @banned_user = users(:banned_user)

    post login_path, params: { login: @banned_user.email, password: "NewPassword1!" }
    assert_equal @banned_user.id, session[:user_id]

    get root_path

    assert_redirected_to root_path
    assert_nil session[:user_id]
    assert_equal "Tu cuenta ha sido baneada.", flash[:alert]
  end
end

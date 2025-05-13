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
    post login_path, params: { login: @user.email, password: "password123" }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
  end

  test "debería iniciar sesión con credenciales correctas (name)" do
    post login_path, params: { login: @user.name, password: "password123" }
    assert_redirected_to root_path
    assert_equal @user.id, session[:user_id]
  end

  test "no debería iniciar sesión con contraseña incorrecta" do
    post login_path, params: { login: @user.email, password: "wrongpass" }
    assert_response :unprocessable_entity   # Esperamos el código de estado 422
    assert_nil session[:user_id]
  end

  test "no debería iniciar sesión con un usuario no existente" do
    post login_path, params: { login: "nonexistent@example.com", password: "whatever" }
    assert_response :unprocessable_entity   # Esperamos el código de estado 422
    assert_nil session[:user_id]
  end

  test "debería cerrar sesión correctamente" do
    post login_path, params: { login: @user.email, password: "password123" }
    assert_equal @user.id, session[:user_id]

    delete logout_path
    assert_redirected_to root_path
    assert_nil session[:user_id]
  end
end

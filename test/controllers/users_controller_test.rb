require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "debería mostrar el formulario de registro" do
    get register_path
    assert_response :success
  end

  test "debería registrar un usuario con datos válidos y recaptcha válido" do
    assert_difference("User.count", 1) do
      post users_path, params: {
        user: {
          name: "Carlos Ruiz",
          username: "carlitos",
          email: "carlos@example.com",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    assert_redirected_to root_path
    follow_redirect!
    assert_match "Registrado correctamente", response.body
  end

  test "no debería registrar usuario si los datos son inválidos" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          name: "",
          username: "",
          email: "noesemail",
          password: "123",
          password_confirmation: "456"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Error al registrar usuario", response.body
  end
end

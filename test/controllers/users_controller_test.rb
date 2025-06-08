require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

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
          password: "NewPassword1!",
          password_confirmation: "NewPassword1!"
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

  test "requiere login para editar contraseña" do
    get edit_password_path
    assert_redirected_to login_path
  end

  test "muestra formulario de cambio de contraseña con usuario logueado" do
    log_in_as(@user)
    get edit_password_path
    assert_response :success
    assert_select "form"
  end

  test "actualiza la contraseña correctamente con datos válidos" do
    log_in_as(@user)
    patch update_password_path, params: {
      user: {
        current_password: "NewPassword1!",
        password: "NewPassword1!",
        password_confirmation: "NewPassword1!"
      }
    }
    assert_redirected_to profile_path
    follow_redirect!
    assert_match "Contraseña actualizada correctamente", response.body
    @user.reload
    assert @user.authenticate("NewPassword1!")
  end

  test "no actualiza si contraseña actual es incorrecta" do
    log_in_as(@user)
    patch update_password_path, params: {
      user: {
        current_password: "wrongpassword",
        password: "NewPassword1!",
        password_confirmation: "NewPassword1!"
      }
    }
    assert_response :unprocessable_entity
    assert_match "La contraseña actual es incorrecta.", response.body
  end

  test "no actualiza si nuevas contraseñas no coinciden" do
    log_in_as(@user)
    patch update_password_path, params: {
      user: {
        current_password: "NewPassword1!",
        password: "NewPassword1!",
        password_confirmation: "Different1!"
      }
    }
    assert_response :unprocessable_entity
    assert_match "Las nuevas contraseñas no coinciden.", response.body
  end
end

require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contact_message = contact_messages(:one)
    @admin = users(:one)
    @user = users(:two)
  end

  test "debería mostrar el formulario de contacto" do
    get contact_url
    assert_response :success
    assert_select "form"
  end

  test "debería crear un mensaje de contacto con parámetros válidos" do
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

    assert_redirected_to root_path
    assert_equal "Tu mensaje ha sido enviado correctamente.", flash[:notice]
  end

  test "no debería crear un mensaje de contacto con parámetros inválidos" do
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
    assert_equal "La creación del mensaje falló.", flash[:alert]
  end

  test "debería mostrar el mensaje de contacto si está autorizado" do
    log_in_as(@admin)
    get contact_message_url(@contact_message)
    assert_response :success
    assert_match @contact_message.subject, @response.body
  end

  test "debería redirigir si no está autorizado a ver el mensaje de contacto" do
    log_in_as(@user)

    get contact_message_url(@contact_message)
    assert_redirected_to root_path
    assert_equal "No estás autorizado para acceder a esta página.", flash[:alert]
  end
end

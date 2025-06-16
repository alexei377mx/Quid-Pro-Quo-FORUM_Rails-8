require "test_helper"

class ContactMessageTest < ActiveSupport::TestCase
  def setup
    @message = contact_messages(:one)
  end

  test "debería ser válido con todos los atributos" do
    assert @message.valid?
  end

  test "debería ser inválido sin nombre" do
    @message.name = ""
    assert_not @message.valid?
    assert_includes @message.errors[:name], "no puede estar en blanco"
  end

  test "debería ser inválido sin correo electrónico" do
    @message.email = ""
    assert_not @message.valid?
    assert_includes @message.errors[:email], "no puede estar en blanco"
  end

  test "debería ser inválido con correo electrónico mal formado" do
    @message.email = "invalid_email"
    assert_not @message.valid?
    assert_includes @message.errors[:email], "no es válido"
  end

  test "debería ser inválido sin asunto" do
    @message.subject = ""
    assert_not @message.valid?
    assert_includes @message.errors[:subject], "no puede estar en blanco"
  end

  test "debería ser inválido sin mensaje" do
    @message.message = ""
    assert_not @message.valid?
    assert_includes @message.errors[:message], "no puede estar en blanco"
  end

  test "el scope by_reviewed debería filtrar correctamente" do
    reviewed = ContactMessage.create!(
      name: "Revisado",
      email: "ok@example.com",
      subject: "Revisado",
      message: "Mensaje leído",
      reviewed: true
    )

    not_reviewed = ContactMessage.create!(
      name: "No Revisado",
      email: "no@example.com",
      subject: "No revisado",
      message: "Mensaje no leído",
      reviewed: false
    )

    assert_includes ContactMessage.by_reviewed(true), reviewed
    assert_not_includes ContactMessage.by_reviewed(true), not_reviewed

    assert_includes ContactMessage.by_reviewed(false), not_reviewed
    assert_not_includes ContactMessage.by_reviewed(false), reviewed
  end

  test "el scope by_date_range debería filtrar mensajes en el rango de fechas" do
    in_range = ContactMessage.create!(
      name: "Dentro del rango",
      email: "rango@example.com",
      subject: "Asunto",
      message: "Mensaje",
      created_at: 3.days.ago
    )

    out_of_range = ContactMessage.create!(
      name: "Fuera del rango",
      email: "fuera@example.com",
      subject: "Asunto",
      message: "Mensaje",
      created_at: 10.days.ago
    )

    from = 5.days.ago.to_date
    to = Date.today

    results = ContactMessage.by_date_range(from, to)

    assert_includes results, in_range
    assert_not_includes results, out_of_range
  end
end

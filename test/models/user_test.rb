require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
  end

  test "debería ser válido con atributos válidos" do
    assert @admin.valid?
    assert @user.valid?
  end

  test "el nombre debería estar presente" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "el nombre de usuario debería estar presente y ser único" do
    @user.username = ""
    assert_not @user.valid?

    duplicate = @admin.dup
    duplicate.username = @user.username
    assert_not duplicate.valid?
  end

  test "el rol debería estar presente" do
    @user.role = nil
    assert_not @user.valid?
  end

  test "el rol debería ser válido (user, admin, moderator)" do
    @user.role = "hacker"
    assert_not @user.valid?
  end

  test "el rol por defecto debería ser 'user' si no está establecido" do
    nuevo = User.new(
      name: "Carlos",
      username: "carlitos",
      password: "pass123",
      password_confirmation: "pass123"
    )
    nuevo.validate
    assert_equal "user", nuevo.role
  end

  test "debería autenticar con la contraseña correcta" do
    assert @admin.authenticate("NewPassword1!")
    assert @user.authenticate("NewPassword1!")
  end

  test "no debería autenticar con la contraseña incorrecta" do
    assert_not @admin.authenticate("wrong")
  end

  test "debería rechazar contraseña que no cumple el formato" do
    @user.password = "nopassword"
    @user.password_confirmation = "nopassword"
    assert_not @user.valid?
    assert_includes @user.errors[:password], "debe incluir al menos una letra mayúscula, una letra minúscula, un número y un carácter especial (por ejemplo: !, @, #, $, %, &, *)."
  end

  test "debería aceptar avatar válido" do
    @user.avatar.attach(
      io: file_fixture("user.jpeg").open,
      filename: "user.jpeg",
      content_type: "image/jpeg"
    )
    assert @user.valid?
  end

  test "debería rechazar avatar con tipo no permitido" do
    @user.avatar.attach(
      io: file_fixture("invalid_file.pdf").open,
      filename: "invalid_file.pdf",
      content_type: "application/pdf"
    )
    assert_not @user.valid?
    assert_includes @user.errors[:image], "debe ser JPEG, PNG o WebP"
  end

  test "debería rechazar avatar demasiado grande" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("a" * 2.megabytes),
      filename: "large_image.jpg",
      content_type: "image/jpeg"
    )
    @user.avatar.attach(blob)
    assert_not @user.valid?
    assert_includes @user.errors[:image], "es demasiado grande (máximo 1 MB)"
  end
end

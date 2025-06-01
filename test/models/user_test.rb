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
    assert @admin.authenticate("password123")
    assert @user.authenticate("password123")
  end

  test "no debería autenticar con la contraseña incorrecta" do
    assert_not @admin.authenticate("wrong")
  end
end

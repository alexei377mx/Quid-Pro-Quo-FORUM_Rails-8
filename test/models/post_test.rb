require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @post = posts(:one)
  end

  test "debería ser válido con atributos válidos" do
    assert @post.valid?
  end

  test "debería ser inválido sin título" do
    @post.title = ""
    assert_not @post.valid?
    assert_includes @post.errors[:title], "no puede estar en blanco"
  end

  test "debería ser inválido si el título es muy corto" do
    @post.title = "Hey"
    assert_not @post.valid?
    assert_includes @post.errors[:title], "es demasiado corto (5 caracteres mínimo)"
  end

  test "debería ser inválido sin contenido" do
    @post.content = ""
    assert_not @post.valid?
    assert_includes @post.errors[:content], "no puede estar en blanco"
  end

  test "debería pertenecer a un usuario" do
    assert_instance_of User, @post.user
  end

  test "debería ser inválido sin un usuario asociado" do
    @post.user = nil
    assert_not @post.valid?
    assert_includes @post.errors[:user], "debe existir"
  end
end

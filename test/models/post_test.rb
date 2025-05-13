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
    assert_includes @post.errors[:title], "can't be blank"
  end

  test "debería ser inválido si el título es muy corto" do
    @post.title = "Hey"
    assert_not @post.valid?
    assert_includes @post.errors[:title], "is too short (minimum is 5 characters)"
  end

  test "debería ser inválido sin contenido" do
    @post.content = ""
    assert_not @post.valid?
    assert_includes @post.errors[:content], "can't be blank"
  end

  test "debería pertenecer a un usuario" do
    assert_instance_of User, @post.user
  end

  test "debería ser inválido sin un usuario asociado" do
    @post.user = nil
    assert_not @post.valid?
    assert_includes @post.errors[:user], "must exist"
  end
end

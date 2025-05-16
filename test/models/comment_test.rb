require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @comentario = comments(:one)
  end

  test "debe ser válido con atributos correctos" do
    assert @comentario.valid?
  end

  test "debe requerir contenido" do
    @comentario.content = nil
    assert_not @comentario.valid?
    assert_includes @comentario.errors[:content], "no puede estar en blanco"
  end

  test "debe requerir contenido con longitud mínima" do
    @comentario.content = "A"
    assert_not @comentario.valid?
    assert_includes @comentario.errors[:content], "es demasiado corto (2 caracteres mínimo)"
  end

  test "debe pertenecer a una publicación" do
    assert_equal posts(:one), @comentario.post
  end

  test "debe pertenecer a un usuario" do
    assert_equal users(:one), @comentario.user
  end

  test "puede tener un comentario padre (auto-relación)" do
    padre = comments(:one)
    respuesta = Comment.new(
      content: "Esta es una respuesta válida",
      post: padre.post,
      user: padre.user,
      parent: padre
    )
    assert respuesta.valid?
    assert_equal padre, respuesta.parent
  end

  test "debe eliminar las respuestas si se elimina el comentario padre" do
    padre = Comment.create!(
      content: "Comentario principal",
      post: posts(:one),
      user: users(:one)
    )

    Comment.create!(
      content: "Respuesta al comentario principal",
      post: padre.post,
      user: padre.user,
      parent: padre
    )

    assert_difference "Comment.count", -2 do
      padre.destroy
    end
  end
end

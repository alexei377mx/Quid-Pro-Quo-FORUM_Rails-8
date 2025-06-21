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

  test "debería aceptar una imagen JPEG válida" do
    @post.image.attach(io: file_fixture("user.jpeg").open, filename: "user.jpeg", content_type: "image/jpeg")
    assert @post.valid?, "La imagen JPEG debería ser válida"
  end

  test "debería rechazar un archivo con tipo no permitido" do
    @post.image.attach(
      io: file_fixture("invalid_file.pdf").open,
      filename: "invalid_file.pdf",
      content_type: "application/pdf"
    )

    assert_not @post.valid?
    assert_includes @post.errors[:image], "debe ser JPEG, PNG o WebP"
  end


  test "debería rechazar una imagen demasiado grande" do
    large_file = StringIO.new("0" * 6.megabytes)
    @post.image.attach(io: large_file, filename: "big_image.jpeg", content_type: "image/jpeg")
    assert_not @post.valid?
    assert_includes @post.errors[:image], "es demasiado grande (máximo 5 MB)"
  end

  test "debería eliminar la imagen si remove_image es true" do
    @post.image.attach(io: file_fixture("user.jpeg").open, filename: "user.jpeg", content_type: "image/jpeg")
    @post.save
    assert @post.image.attached?, "La imagen debería estar adjunta"

    @post.remove_image = true
    @post.save
    @post.reload

    assert_not @post.image.attached?, "La imagen debería haber sido eliminada"
  end
end

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post_one = posts(:one)
    @post_two = posts(:two)
    @user_one = users(:one)
    @user_two = users(:two)
  end

  test "debería obtener el índice" do
    get posts_url
    assert_response :success
  end

  test "debería mostrar una publicación" do
    get post_url(@post_one)
    assert_response :success
  end

  test "debería redirigir a iniciar sesión al intentar acceder a nuevo sin estar autenticado" do
    get new_post_url
    assert_redirected_to login_url
  end

  test "debería acceder a nuevo cuando el usuario ha iniciado sesión" do
    log_in_as(@user_one)
    get new_post_url
    assert_response :success
  end

  test "debería crear una publicación" do
    log_in_as(@user_one)
    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: { title: "Nuevo Título", content: "Nuevo contenido", category: "Tecnología" }
      }
    end

    nueva_post = Post.last
    assert_redirected_to post_url(nueva_post)
    assert_equal @user_one, nueva_post.user
  end

  test "no debería crear una publicación si no ha iniciado sesión" do
    assert_no_difference("Post.count") do
      post posts_url, params: {
        post: { title: "Nuevo Título", content: "Nuevo contenido" }
      }
    end
    assert_redirected_to login_url
  end

  test "debería acceder a editar si es el propietario" do
    log_in_as(@user_one)
    get edit_post_url(@post_one)
    assert_response :success
  end

  test "debería redirigir al intentar editar si no es el propietario" do
    log_in_as(@user_two)
    get edit_post_url(@post_one)
    assert_redirected_to posts_url
    assert_equal "No estás autorizado para realizar esta acción.", flash[:alert]
  end

  test "debería actualizar la publicación si es el propietario" do
    log_in_as(@user_one)
    patch post_url(@post_one), params: {
      post: { title: "Título Actualizado" }
    }
    assert_redirected_to post_url(@post_one)
    @post_one.reload
    assert_equal "Título Actualizado", @post_one.title
  end

  test "no debería actualizar la publicación si no es el propietario" do
    log_in_as(@user_two)
    patch post_url(@post_one), params: {
      post: { title: "Título Hackeado" }
    }
    assert_redirected_to posts_url
    @post_one.reload
    refute_equal "Título Hackeado", @post_one.title
  end

  test "debería eliminar la publicación si es el propietario" do
    log_in_as(@user_one)
    assert_difference("Post.count", -1) do
      delete post_url(@post_one)
    end
    assert_redirected_to posts_url
  end

  test "no debería eliminar la publicación si no es el propietario" do
    log_in_as(@user_two)
    assert_no_difference("Post.count") do
      delete post_url(@post_one)
    end
    assert_redirected_to posts_url
  end

  test "admin debería poder marcar post como eliminado por admin" do
    log_in_as(@user_one)
    patch admin_destroy_post_post_url(@post_two)
    assert_redirected_to posts_url
    assert_equal "Publicación eliminada por administración.", flash[:alert]
    @post_two.reload
    assert @post_two.deleted_by_admin?
  end

  test "usuario normal no debería poder marcar post como eliminado por admin" do
    log_in_as(@user_two)
    patch admin_destroy_post_post_url(@post_one)
    assert_redirected_to root_path
    assert_equal "No estás autorizado para acceder a esta página.", flash[:alert]
    @post_one.reload
    refute @post_one.deleted_by_admin?
  end

  test "mostrar alerta si post fue eliminado por admin al intentar verlo" do
    @post_one.update_column(:deleted_by_admin, true)
    get post_url(@post_one)
    assert_redirected_to posts_url
    assert_equal "Esta publicación fue eliminada por la administración.", flash[:alert]
  end

  test "debería crear una publicación con imagen válida" do
    log_in_as(@user_one)

    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: {
          title: "Post con imagen",
          content: "Contenido con imagen",
          category: "Tecnología",
          image: fixture_file_upload("user.jpeg", "image/jpeg")
        }
      }
    end

    post_creado = Post.last
    assert post_creado.image.attached?, "La imagen debería estar adjunta"
    assert_redirected_to post_url(post_creado)
  end

  test "debería rechazar imagen inválida al crear publicación" do
    log_in_as(@user_one)

    assert_no_difference("Post.count") do
      post posts_url, params: {
        post: {
          title: "Post con archivo inválido",
          content: "Intento con PDF",
          category: "Tecnología",
          image: fixture_file_upload("invalid_file.pdf")
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "debería eliminar la imagen si se marca remove_image en update" do
    log_in_as(@user_one)

    @post_one.image.attach(io: file_fixture("user.jpeg").open, filename: "user.jpeg", content_type: "image/jpeg")
    @post_one.save
    assert @post_one.image.attached?

    patch post_url(@post_one), params: {
      post: {
        title: @post_one.title,
        content: @post_one.content,
        category: @post_one.category,
        remove_image: "1"
      }
    }

    @post_one.reload
    assert_not @post_one.image.attached?, "La imagen debería haberse eliminado"
    assert_redirected_to post_url(@post_one)
  end
end

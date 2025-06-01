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
end

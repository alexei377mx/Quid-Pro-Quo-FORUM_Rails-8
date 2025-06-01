require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @comentario = comments(:one)
    @usuario = users(:one)
    @otro_usuario = users(:two)
  end

  test "debe redirigir si no has iniciado sesión al crear comentario" do
    assert_no_difference "Comment.count" do
      post post_comments_path(@post), params: { comment: { content: "Nuevo comentario" } }
    end
    assert_redirected_to login_path
    follow_redirect!
    assert_match "Debes iniciar sesión", response.body
  end

  test "debe crear comentario si el usuario ha iniciado sesión" do
    log_in_as(@usuario)

    assert_difference "Comment.count", 1 do
      post post_comments_path(@post), params: {
        comment: { content: "Un comentario válido" }
      }
    end

    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_match "El comentario fue publicado exitosamente", response.body
  end

  test "no debe crear comentario inválido" do
    log_in_as(@usuario)

    assert_no_difference "Comment.count" do
      post post_comments_path(@post), params: {
        comment: { content: "" }
      }
    end

    assert_response :unprocessable_entity
    assert_match "Hubo un error al publicar el comentario", response.body
  end

  test "debe permitir responder a un comentario" do
    log_in_as(@usuario)

    assert_difference "Comment.count", 1 do
      post reply_post_comment_path(@post, @comentario), params: {
        comment: { content: "Esta es una respuesta" }
      }
    end

    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_match "La respuesta fue publicada exitosamente", response.body
  end

  test "no debe permitir editar comentario de otro usuario" do
    log_in_as(@otro_usuario)

    get edit_post_comment_path(@post, @comentario)
    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_match "No estás autorizado", response.body
  end

  test "debe permitir editar su propio comentario" do
    log_in_as(@usuario)

    get edit_post_comment_path(@post, @comentario)
    assert_response :success
  end

  test "debe actualizar comentario válido" do
    log_in_as(@usuario)

    patch post_comment_path(@post, @comentario), params: {
      comment: { content: "Comentario actualizado" }
    }

    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_match "El comentario fue actualizado exitosamente", response.body
  end

  test "no debe actualizar comentario inválido" do
    log_in_as(@usuario)

    patch post_comment_path(@post, @comentario), params: {
      comment: { content: "" }
    }

    assert_response :unprocessable_entity
  end

  test "no debe permitir eliminar comentario si no es admin" do
    log_in_as(@otro_usuario)

    patch soft_delete_post_comment_path(@post, @comentario)
    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_match "No estás autorizado", response.body
    @comentario.reload
    assert_not @comentario.deleted_by_admin
  end

  test "debe permitir eliminar comentario si es admin" do
    log_in_as(@usuario)

    patch soft_delete_post_comment_path(@post, @comentario)
    assert_redirected_to post_path(@post)
    follow_redirect!
    assert_match "Comentario eliminado por administración", response.body
    @comentario.reload
    assert @comentario.deleted_by_admin
  end
end

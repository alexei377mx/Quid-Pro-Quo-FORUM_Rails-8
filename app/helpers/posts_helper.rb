module PostsHelper
  # Formatea la fecha de publicación en formato "hace X tiempo"
  def post_published_time(post)
    "hace #{time_ago_in_words(post.created_at)}"
  end

  # Formatea la fecha de edición si aplica
  def post_edited_time(post)
    return unless post.updated_at > post.created_at
    "Editado hace #{time_ago_in_words(post.updated_at)}"
  end

  # Verifica si el usuario actual es el autor del post
  def can_edit_post?(post)
    user_signed_in? && post.user == current_user
  end
end

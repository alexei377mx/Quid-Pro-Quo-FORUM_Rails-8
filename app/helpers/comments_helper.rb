module CommentsHelper
  def comment_liked_by_user?(comment)
    user_signed_in? && comment.liked_by_users.include?(current_user)
  end

  def comment_edit_link(comment, post)
    return unless user_signed_in? && comment.user == current_user

    link_to "<i class='fa-solid fa-pen'></i> Editar".html_safe, edit_post_comment_path(post, comment)
  end
end

module CommentsHelper
  def comment_liked_by_user?(comment)
    user_signed_in? && comment.liked_by_users.include?(current_user)
  end

  def comment_edit_link(comment, post)
    return unless user_signed_in? && comment.user == current_user

    link_to(
      "<i class='fa-solid fa-pen'></i> #{t('comments.helper.edit')}".html_safe,
      edit_post_comment_path(post, comment)
    )
  end

  def time_ago(comment)
    t("comments.helper.posted_ago", time: time_ago_in_words(comment.created_at))
  end

  def edited_time_ago(comment)
    return unless comment.edited?

    t("comments.helper.edited_ago", time: time_ago_in_words(comment.updated_at))
  end

  def reply_form_object(comment)
    if @reply_with_errors&.parent_id == comment.id
      @reply_with_errors
    else
      Comment.new(parent_id: comment.id)
    end
  end

  def name_and_username(user)
    return "" unless user

    "#{user.name} (@#{user.username})".html_safe
  end
end

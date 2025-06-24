module PostsHelper
  def post_published_time(post)
    t("posts.helper.published_ago", time: time_ago_in_words(post.created_at))
  end

  def post_edited_time(post)
    return unless post.updated_at > post.created_at

    t("posts.helper.edited_ago", time: time_ago_in_words(post.updated_at))
  end

  def can_edit_post?(post)
    user_signed_in? && post.user == current_user
  end

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new(filter_html: true, hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer, {
      autolink: true,
      fenced_code_blocks: true,
      strikethrough: true,
      tables: true,
      underline: true,
      highlight: true,
      quote: true,
      footnotes: true
    })
    markdown.render(text).html_safe
  end

  def name_and_username(user)
    return "" unless user

    "#{user.name} (@#{user.username})".html_safe
  end

  def categories_options
    Post::CATEGORIES.sort.map do |id, symbol|
      [ I18n.t("posts.categories.#{symbol}"), id ]
    end
  end
end

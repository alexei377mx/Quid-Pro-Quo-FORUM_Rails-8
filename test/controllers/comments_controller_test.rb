require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @comment = comments(:one)
    @user = users(:one)
    @other_user = users(:two)
  end

  test "should redirect create when not logged in" do
    assert_no_difference "Comment.count" do
      post post_comments_path(@post), params: { comment: { content: "New comment" } }
    end
    assert_redirected_to login_path(locale: I18n.locale)
    follow_redirect!
    assert_match I18n.t("comments.controller.login_required"), response.body
  end

  test "should create comment when logged in" do
    log_in_as(@user)

    assert_difference "Comment.count", 1 do
      post post_comments_path(@post), params: {
        comment: { content: "A valid comment" }
      }
    end

    assert_redirected_to post_path(@post, locale: I18n.locale)
    follow_redirect!
    assert_match I18n.t("comments.controller.created"), response.body
  end

  test "should not create invalid comment" do
    log_in_as(@user)

    assert_no_difference "Comment.count" do
      post post_comments_path(@post), params: {
        comment: { content: "" }
      }
    end

    assert_response :unprocessable_entity
    assert_match I18n.t("comments.controller.create_error"), response.body
  end

  test "should allow replying to comment" do
    log_in_as(@user)

    assert_difference "Comment.count", 1 do
      post reply_post_comment_path(@post, @comment), params: {
        comment: { content: "This is a reply" }
      }
    end

    assert_redirected_to post_path(@post, locale: I18n.locale)
    follow_redirect!
    assert_match I18n.t("comments.controller.reply_created"), response.body
  end

  test "should not allow editing another user's comment" do
    log_in_as(@other_user)

    get edit_post_comment_path(@post, @comment)
    assert_redirected_to post_path(@post, locale: I18n.locale)
    follow_redirect!
    assert_match I18n.t("comments.controller.unauthorized"), response.body
  end

  test "should allow editing own comment" do
    log_in_as(@user)

    get edit_post_comment_path(@post, @comment)
    assert_response :success
  end

  test "should update valid comment" do
    log_in_as(@user)

    patch post_comment_path(@post, @comment), params: {
      comment: { content: "Updated comment" }
    }

    assert_redirected_to post_path(@post, locale: I18n.locale)
    follow_redirect!
    assert_match I18n.t("comments.controller.updated"), response.body
  end

  test "should not update invalid comment" do
    log_in_as(@user)

    patch post_comment_path(@post, @comment), params: {
      comment: { content: "" }
    }

    assert_response :unprocessable_entity
  end

  test "should not allow deleting comment if not admin" do
    log_in_as(@other_user)

    patch admin_destroy_comment_post_comment_path(@post, @comment)
    assert_redirected_to post_path(@post, locale: I18n.locale)
    follow_redirect!
    assert_match I18n.t("comments.controller.unauthorized"), response.body
    @comment.reload
    assert_not @comment.deleted_by_admin
  end

  test "should allow deleting comment if admin" do
    log_in_as(@user)

    patch admin_destroy_comment_post_comment_path(@post, @comment)
    assert_redirected_to post_path(@post, locale: I18n.locale)
    follow_redirect!
    assert_match I18n.t("comments.controller.admin_deleted"), response.body
    @comment.reload
    assert @comment.deleted_by_admin
  end
end

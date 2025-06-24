require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post_one = posts(:one)
    @post_two = posts(:two)
    @user_one = users(:one)
    @user_two = users(:two)
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should show post" do
    get post_url(@post_one)
    assert_response :success
  end

  test "should redirect to login when trying to access new while unauthenticated" do
    get new_post_url
    assert_redirected_to login_url(locale: I18n.locale)
  end

  test "should access new when user is logged in" do
    log_in_as(@user_one)
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    log_in_as(@user_one)
    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: { title: "New Title", content: "New content", category: "1" }
      }
    end

    new_post = Post.last
    assert_redirected_to post_url(new_post, locale: I18n.locale)
    assert_equal @user_one, new_post.user
  end

  test "should not create post when not logged in" do
    assert_no_difference("Post.count") do
      post posts_url, params: {
        post: { title: "New Title", content: "New content" }
      }
    end
    assert_redirected_to login_url(locale: I18n.locale)
  end

  test "should access edit if owner" do
    log_in_as(@user_one)
    get edit_post_url(@post_one)
    assert_response :success
  end

  test "should redirect when trying to edit if not owner" do
    log_in_as(@user_two)
    get edit_post_url(@post_one)
    assert_redirected_to posts_url(locale: I18n.locale)
    assert_equal I18n.t("posts.controller.unauthorized"), flash[:alert]
  end

  test "should update post if owner" do
    log_in_as(@user_one)
    patch post_url(@post_one), params: {
      post: {
        title: "Updated Title",
        content: @post_one.content,
        category: @post_one.category
      }
    }
    assert_redirected_to post_url(@post_one, locale: I18n.locale)
    @post_one.reload
    assert_equal "Updated Title", @post_one.title
  end

  test "should not update post if not owner" do
    log_in_as(@user_two)
    patch post_url(@post_one), params: {
      post: { title: "Hacked Title" }
    }
    assert_redirected_to posts_url(locale: I18n.locale)
    @post_one.reload
    refute_equal "Hacked Title", @post_one.title
  end

  test "should delete post if owner" do
    log_in_as(@user_one)
    assert_difference("Post.count", -1) do
      delete post_url(@post_one)
    end
    assert_redirected_to posts_url(locale: I18n.locale)
  end

  test "should not delete post if not owner" do
    log_in_as(@user_two)
    assert_no_difference("Post.count") do
      delete post_url(@post_one)
    end
    assert_redirected_to posts_url(locale: I18n.locale)
  end

  test "admin should be able to mark post as deleted by admin" do
    log_in_as(@user_one)
    patch admin_destroy_post_post_url(@post_two)
    assert_redirected_to posts_url(locale: I18n.locale)
    assert_equal I18n.t("posts.controller.admin_deleted"), flash[:alert]
    @post_two.reload
    assert @post_two.deleted_by_admin?
  end

  test "regular user should not be able to mark post as deleted by admin" do
    log_in_as(@user_two)
    patch admin_destroy_post_post_url(@post_one)
    assert_redirected_to root_url(locale: I18n.locale)
    assert_equal I18n.t("errors.not_authorized"), flash[:alert]
    @post_one.reload
    refute @post_one.deleted_by_admin?
  end

  test "should show alert when post was deleted by admin" do
    @post_one.update_column(:deleted_by_admin, true)
    get post_url(@post_one)
    assert_redirected_to posts_url(locale: I18n.locale)
    assert_equal I18n.t("posts.controller.deleted_by_admin"), flash[:alert]
  end

  test "should create post with valid image" do
    log_in_as(@user_one)

    assert_difference("Post.count", 1) do
      post posts_url, params: {
        post: {
          title: "Post with image",
          content: "Content with image",
          category: "1",
          image: fixture_file_upload("user.jpeg", "image/jpeg")
        }
      }
    end

    created_post = Post.last
    assert created_post.image.attached?, "Image should be attached"
    assert_redirected_to post_url(created_post, locale: I18n.locale)
  end

  test "should reject invalid image when creating post" do
    log_in_as(@user_one)

    assert_no_difference("Post.count") do
      post posts_url, params: {
        post: {
          title: "Post with invalid file",
          content: "Attempt with PDF",
          category: @post_one.category,
          image: fixture_file_upload("invalid_file.pdf")
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should remove image when remove_image is checked in update" do
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
    assert_not @post_one.image.attached?, "Image should have been removed"
    assert_redirected_to post_url(@post_one, locale: I18n.locale)
  end
end

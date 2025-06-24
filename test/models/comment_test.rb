require "test_helper"

class CommentTest < ActiveSupport::TestCase
  def setup
    @comment = comments(:one)
  end

  test "should be valid with correct attributes" do
    assert @comment.valid?
  end

  test "should require content" do
    @comment.content = nil
    assert_not @comment.valid?
    assert_includes @comment.errors[:content], I18n.t("errors.messages.blank")
  end

  test "should require minimum content length" do
    @comment.content = "A"
    assert_not @comment.valid?
    assert_includes @comment.errors[:content],
                   I18n.t("errors.messages.too_short", count: 2)
  end

  test "should belong to a post" do
    assert_equal posts(:one), @comment.post
  end

  test "should belong to a user" do
    assert_equal users(:one), @comment.user
  end

  test "can have a parent comment (self-relationship)" do
    parent = comments(:one)
    reply = Comment.new(
      content: "This is a valid reply",
      post: parent.post,
      user: parent.user,
      parent: parent
    )
    assert reply.valid?
    assert_equal parent, reply.parent
  end

  test "should delete replies when parent comment is deleted" do
    parent = Comment.create!(
      content: "Main comment",
      post: posts(:one),
      user: users(:one)
    )

    Comment.create!(
      content: "Reply to main comment",
      post: parent.post,
      user: parent.user,
      parent: parent
    )

    assert_difference "Comment.count", -2 do
      parent.destroy
    end
  end
end

require "test_helper"

class PostTest < ActiveSupport::TestCase
  def setup
    @post = posts(:one)
  end

  test "should be valid with valid attributes" do
    assert @post.valid?
  end

  test "should be invalid without title" do
    @post.title = ""
    assert_not @post.valid?
    assert_includes @post.errors[:title], I18n.t("errors.messages.blank")
  end

  test "should be invalid with too short title" do
    @post.title = "Hey"
    assert_not @post.valid?
    assert_includes @post.errors[:title],
                   I18n.t("errors.messages.too_short", count: 5)
  end

  test "should be invalid without content" do
    @post.content = ""
    assert_not @post.valid?
    assert_includes @post.errors[:content], I18n.t("errors.messages.blank")
  end

  test "should belong to a user" do
    assert_instance_of User, @post.user
  end

  test "should be invalid without an associated user" do
    @post.user = nil
    assert_not @post.valid?
    assert_includes @post.errors[:user], I18n.t("errors.messages.required")
  end

  test "should accept valid JPEG image" do
    @post.image.attach(io: file_fixture("user.jpeg").open, filename: "user.jpeg", content_type: "image/jpeg")
    assert @post.valid?, "JPEG image should be valid"
  end

  test "should reject file with invalid type" do
    @post.image.attach(
      io: file_fixture("invalid_file.pdf").open,
      filename: "invalid_file.pdf",
      content_type: "application/pdf"
    )

    assert_not @post.valid?
    assert_includes @post.errors[:image],
                   I18n.t("activerecord.errors.models.post.attributes.image.invalid_format")
  end

  test "should reject image that is too large" do
    large_file = StringIO.new("0" * 6.megabytes)
    @post.image.attach(io: large_file, filename: "big_image.jpeg", content_type: "image/jpeg")
    assert_not @post.valid?
    assert_includes @post.errors[:image],
                   I18n.t("activerecord.errors.models.post.attributes.image.too_large")
  end

  test "should remove image when remove_image is true" do
    @post.image.attach(io: file_fixture("user.jpeg").open, filename: "user.jpeg", content_type: "image/jpeg")
    @post.save
    assert @post.image.attached?, "Image should be attached"

    @post.remove_image = true
    @post.save
    @post.reload

    assert_not @post.image.attached?, "Image should have been removed"
  end
end

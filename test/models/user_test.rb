require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @admin = users(:one)
    @user = users(:two)
  end

  test "should be valid with valid attributes" do
    assert @admin.valid?
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
    assert_includes @user.errors[:name], I18n.t("errors.messages.blank")
  end

  test "username should be present and unique" do
    @user.username = ""
    assert_not @user.valid?
    assert_includes @user.errors[:username], I18n.t("errors.messages.blank")

    duplicate = @admin.dup
    duplicate.username = @user.username
    assert_not duplicate.valid?
  end

  test "role should be present" do
    @user.role = nil
    assert_not @user.valid?
    assert_includes @user.errors[:role], I18n.t("errors.messages.blank")
  end

  test "role should be valid (user, admin, moderator)" do
    @user.role = "hacker"
    assert_not @user.valid?
    assert_includes @user.errors[:role],
                   I18n.t("activerecord.errors.models.user.attributes.role.invalid_role")
  end

  test "default role should be 'user' if not set" do
    new_user = User.new(
      name: "Carlos",
      username: "carlitos",
      password: "pass123",
      password_confirmation: "pass123"
    )
    new_user.validate
    assert_equal "user", new_user.role
  end

  test "should authenticate with correct password" do
    assert @admin.authenticate("NewPassword1!")
    assert @user.authenticate("NewPassword1!")
  end

  test "should not authenticate with wrong password" do
    assert_not @admin.authenticate("wrong")
  end

  test "should reject password that doesn't meet format" do
    @user.password = "nopassword"
    @user.password_confirmation = "nopassword"
    assert_not @user.valid?
    assert_includes @user.errors[:password],
                   I18n.t("activerecord.errors.models.user.attributes.password.invalid_password_format")
  end

  test "should accept valid avatar" do
    @user.avatar.attach(
      io: file_fixture("user.jpeg").open,
      filename: "user.jpeg",
      content_type: "image/jpeg"
    )
    assert @user.valid?
  end

  test "should reject avatar with invalid type" do
    @user.avatar.attach(
      io: file_fixture("invalid_file.pdf").open,
      filename: "invalid_file.pdf",
      content_type: "application/pdf"
    )
    assert_not @user.valid?
    assert_includes @user.errors[:avatar],
                   I18n.t("activerecord.errors.models.user.attributes.avatar.avatar_invalid_format")
  end

  test "should reject avatar that is too large" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("a" * 2.megabytes),
      filename: "large_image.jpg",
      content_type: "image/jpeg"
    )
    @user.avatar.attach(blob)
    assert_not @user.valid?
    assert_includes @user.errors[:avatar],
                   I18n.t("activerecord.errors.models.user.attributes.avatar.avatar_too_big")
  end
end

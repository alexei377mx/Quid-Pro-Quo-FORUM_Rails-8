require "test_helper"

class ContactMessageTest < ActiveSupport::TestCase
  def setup
    @message = contact_messages(:one)
  end

  test "should be valid with all attributes" do
    assert @message.valid?
  end

  test "should be invalid without name" do
    @message.name = ""
    assert_not @message.valid?
    assert_includes @message.errors[:name], I18n.t("errors.messages.blank")
  end

  test "should be invalid without email" do
    @message.email = ""
    assert_not @message.valid?
    assert_includes @message.errors[:email], I18n.t("errors.messages.blank")
  end

  test "should be invalid with malformed email" do
    @message.email = "invalid_email"
    assert_not @message.valid?
    assert_includes @message.errors[:email], I18n.t("errors.messages.invalid")
  end

  test "should be invalid without subject" do
    @message.subject = ""
    assert_not @message.valid?
    assert_includes @message.errors[:subject], I18n.t("errors.messages.blank")
  end

  test "should be invalid without message" do
    @message.message = ""
    assert_not @message.valid?
    assert_includes @message.errors[:message], I18n.t("errors.messages.blank")
  end

  test "by_reviewed scope should filter correctly" do
    reviewed = ContactMessage.create!(
      name: "Reviewed",
      email: "ok@example.com",
      subject: "Reviewed",
      message: "Read message",
      reviewed: true
    )

    not_reviewed = ContactMessage.create!(
      name: "Not Reviewed",
      email: "no@example.com",
      subject: "Not reviewed",
      message: "Unread message",
      reviewed: false
    )

    assert_includes ContactMessage.by_reviewed(true), reviewed
    assert_not_includes ContactMessage.by_reviewed(true), not_reviewed

    assert_includes ContactMessage.by_reviewed(false), not_reviewed
    assert_not_includes ContactMessage.by_reviewed(false), reviewed
  end

  test "by_date_range scope should filter messages within date range" do
    in_range = ContactMessage.create!(
      name: "In range",
      email: "range@example.com",
      subject: "Subject",
      message: "Message",
      created_at: 3.days.ago
    )

    out_of_range = ContactMessage.create!(
      name: "Out of range",
      email: "out@example.com",
      subject: "Subject",
      message: "Message",
      created_at: 10.days.ago
    )

    from = 5.days.ago.to_date
    to = Date.today

    results = ContactMessage.by_date_range(from, to)

    assert_includes results, in_range
    assert_not_includes results, out_of_range
  end
end

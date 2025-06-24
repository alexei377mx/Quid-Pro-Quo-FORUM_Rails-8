require "test_helper"

class ReportTest < ActiveSupport::TestCase
  setup do
    @report_post = reports(:one)
    @report_comment = reports(:two)
  end

  test "should be valid with reason id in REASONS" do
    valid_reason_id = Report::REASONS.keys.first.to_s
    @report_post.reason = valid_reason_id
    assert @report_post.valid?, "Report with valid reason should be valid"
  end

  test "should be invalid without reason" do
    @report_post.reason = nil
    assert_not @report_post.valid?
    assert_includes @report_post.errors[:reason], I18n.t("errors.messages.blank")
  end

  test "should be invalid with reason not in REASONS" do
    @report_post.reason = "999"
    assert_not @report_post.valid?
    assert_includes @report_post.errors[:reason],
                   I18n.t("activerecord.errors.models.report.attributes.reason.invalid_reason")
  end

  test "should belong to user" do
    assert_equal users(:one), @report_post.user
  end

  test "should belong to polymorphic reportable (post or comment)" do
    assert_kind_of Post, @report_post.reportable
    assert_kind_of Comment, @report_comment.reportable
  end
end

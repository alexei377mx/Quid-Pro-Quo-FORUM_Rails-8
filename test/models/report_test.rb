require "test_helper"

class ReportTest < ActiveSupport::TestCase
  setup do
    @report_post = reports(:one)
    @report_comment = reports(:two)
  end

  test "valid report with reason in REASONS" do
    valid_reason = Report::REASONS.first
    @report_post.reason = valid_reason
    assert @report_post.valid?, "El reporte con razón válida debería ser válido"
  end

  test "invalid report without reason" do
    @report_post.reason = nil
    assert_not @report_post.valid?
    assert_includes @report_post.errors[:reason], "no puede estar en blanco"
  end

  test "invalid report with reason not in REASONS" do
    @report_post.reason = "Razón inválida"
    assert_not @report_post.valid?
    assert_includes @report_post.errors[:reason], "no es una razón válida"
  end

  test "report belongs to user" do
    assert_equal users(:one), @report_post.user
  end

  test "report belongs to polymorphic reportable (post or comment)" do
    assert_kind_of Post, @report_post.reportable
    assert_kind_of Comment, @report_comment.reportable
  end
end

require "test_helper"

class RadioTest < ActiveSupport::TestCase
  def setup
    @radio = radios(:one)
  end

  test "should be valid with valid attributes" do
    assert @radio.valid?
  end

  test "should require title" do
    @radio.title = ""
    assert_not @radio.valid?
    assert_includes @radio.errors[:title], I18n.t("errors.messages.blank")
  end

  test "should require stream URL" do
    @radio.stream_url = ""
    assert_not @radio.valid?
    assert_includes @radio.errors[:stream_url], I18n.t("errors.messages.blank")
  end
end

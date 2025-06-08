require "test_helper"

class RadioTest < ActiveSupport::TestCase
  def setup
    @radio = radios(:one)
  end

  test "es válido con atributos válidos" do
    assert @radio.valid?
  end

  test "requiere un título" do
    @radio.title = ""
    assert_not @radio.valid?
  end

  test "requiere una URL de stream" do
    @radio.stream_url = ""
    assert_not @radio.valid?
  end
end

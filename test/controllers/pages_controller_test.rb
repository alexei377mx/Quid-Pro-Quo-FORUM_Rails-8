require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "get fair_use" do
    get fair_use_url
    assert_response :success
  end
end

require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "accede a fair_use" do
    get pages_fair_use_url
    assert_response :success
  end
end

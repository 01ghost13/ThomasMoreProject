require 'test_helper'

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should get search_result" do
    get search_search_result_url
    assert_response :success
  end

end

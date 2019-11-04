require 'test_helper'

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  test "should get client_overall" do
    get statistics_client_overall_url
    assert_response :success
  end

  test "should get group_results" do
    get statistics_group_results_url
    assert_response :success
  end

end

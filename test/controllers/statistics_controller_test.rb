require 'test_helper'

class StatisticsControllerTest < ActionDispatch::IntegrationTest
  test "should get student_overall" do
    get statistics_student_overall_url
    assert_response :success
  end

  test "should get group_results" do
    get statistics_group_results_url
    assert_response :success
  end

end

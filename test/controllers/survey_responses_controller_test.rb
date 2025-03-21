require "test_helper"

class SurveyResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    sign_in_as_admin(@user, @account)
    @survey_response = survey_responses(:one)
  end

  test "should create survey_response" do
    assert_difference("SurveyResponse.count") do
      post survey_response_url, params: {survey_response: {responses_attributes: [block_id: blocks(:one).id, response_data: [text: "Short answer"]]}}
    end

    assert_redirected_to thank_you_public_survey_response_url(token: @assessment.token), notice: "Thank you for completing the survey!"
  end
end

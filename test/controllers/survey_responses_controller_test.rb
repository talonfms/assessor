require "test_helper"

class SurveyResponsesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    sign_in_as_admin(@user, @account)
    @survey_response = survey_responses(:one)
    @assessment = assessments(:one)
  end

  test "should create survey_response stamped with a user id and email address with a logged in user" do
    assert_difference("SurveyResponse.count") do
      post public_survey_responses_url, params: {token: @assessment.token, survey_response: {responses_attributes: [block_id: blocks(:one).id, response_data: [text: "Short answer"]]}}
    end

    assert_equal 2, SurveyResponse.where(respondent_id: @user.id).count
    assert_equal 2, SurveyResponse.where(respondent_email: @user.email).count

    assert_redirected_to thank_you_public_survey_response_url(token: @assessment.token), notice: "Thank you for completing the survey!"
  end
end

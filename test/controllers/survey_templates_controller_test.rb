require "test_helper"

class SurveyTemplatesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @account = accounts(:one)
    sign_in_as_admin(@user, @account)
    @survey_template = survey_templates(:one)
    @account.update!(is_parent: true)
  end

  test "should get index" do
    get survey_templates_url
    assert_response :success
  end

  test "should get new" do
    get new_survey_template_url
    assert_response :success
  end

  test "should create survey_template" do
    assert_difference("SurveyTemplate.count") do
      post survey_templates_url, params: {survey_template: {account_id: @survey_template.account_id, description: @survey_template.description, name: @survey_template.name}}
    end

    assert_redirected_to survey_template_url(SurveyTemplate.last)
  end

  test "should show survey_template" do
    get survey_template_url(@survey_template)
    assert_response :success
  end

  test "should get edit" do
    get edit_survey_template_url(@survey_template)
    assert_response :success
  end

  test "should update survey_template" do
    patch survey_template_url(@survey_template), params: {survey_template: {account_id: @survey_template.account_id, description: @survey_template.description, name: @survey_template.name}}
    assert_redirected_to survey_template_url(@survey_template)
  end

  test "should destroy survey_template" do
    assert_difference("SurveyTemplate.count", -1) do
      delete survey_template_url(@survey_template)
    end

    assert_redirected_to survey_templates_url
  end
end

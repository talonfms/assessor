require "application_system_test_case"

class SurveyTemplatesTest < ApplicationSystemTestCase
  setup do
    @survey_template = survey_templates(:one)
  end

  test "visiting the index" do
    visit survey_templates_url
    assert_selector "h1", text: "Survey templates"
  end

  test "should create survey template" do
    visit survey_templates_url
    click_on "New survey template"

    fill_in "Account", with: @survey_template.account_id
    fill_in "Description", with: @survey_template.description
    fill_in "Name", with: @survey_template.name
    click_on "Create Survey template"

    assert_text "Survey template was successfully created"
    click_on "Back"
  end

  test "should update Survey template" do
    visit survey_template_url(@survey_template)
    click_on "Edit this survey template", match: :first

    fill_in "Account", with: @survey_template.account_id
    fill_in "Description", with: @survey_template.description
    fill_in "Name", with: @survey_template.name
    click_on "Update Survey template"

    assert_text "Survey template was successfully updated"
    click_on "Back"
  end

  test "should destroy Survey template" do
    visit survey_template_url(@survey_template)
    click_on "Destroy this survey template", match: :first

    assert_text "Survey template was successfully destroyed"
  end
end

require "application_system_test_case"

class AssessmentsTest < ApplicationSystemTestCase
  setup do
    @assessment = assessments(:one)
  end

  test "visiting the index" do
    visit assessments_url
    assert_selector "h1", text: "Assessments"
  end

  test "should create assessment" do
    visit assessments_url
    click_on "New assessment"

    fill_in "Account", with: @assessment.account_id
    fill_in "Name", with: @assessment.name
    click_on "Create Assessment"

    assert_text "Assessment was successfully created"
    click_on "Back"
  end

  test "should update Assessment" do
    visit assessment_url(@assessment)
    click_on "Edit this assessment", match: :first

    fill_in "Account", with: @assessment.account_id
    fill_in "Name", with: @assessment.name
    click_on "Update Assessment"

    assert_text "Assessment was successfully updated"
    click_on "Back"
  end

  test "should destroy Assessment" do
    visit assessment_url(@assessment)
    click_on "Destroy this assessment", match: :first

    assert_text "Assessment was successfully destroyed"
  end
end

require "test_helper"

class AssessmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as_admin(users(:one), accounts(:one))
    @assessment = assessments(:one)
  end

  test "should get index" do
    get assessments_url
    assert_response :success
  end

  test "should get new" do
    get new_assessment_url
    assert_response :success
  end

  test "should create assessment" do
    assert_difference("Assessment.count") do
      post assessments_url, params: {assessment: {account_id: @assessment.account_id, name: @assessment.name, template_version_id: @assessment.template_version.id}}
    end

    assert_redirected_to assessment_url(Assessment.last)
  end

  test "should show assessment" do
    get assessment_url(@assessment)
    assert_response :success
  end

  test "should get edit" do
    get edit_assessment_url(@assessment)
    assert_response :success
  end

  test "should update assessment without creating an ExportBundle" do
    ExportBundle.destroy_all
    patch assessment_url(@assessment), params: {assessment: {name: @assessment.name}}
    assert_redirected_to assessment_url(@assessment)
    assert_nil ExportBundle.find_by(assessment: @assessment)
  end

  test "should update assessment to submitted and create ExportBundle" do
    ExportBundle.destroy_all
    patch assessment_url(@assessment), params: {assessment: {name: @assessment.name, status: "submitted"}}
    assert_redirected_to assessment_url(@assessment)
    assert_not_nil ExportBundle.find_by(assessment: @assessment)
    assert_equal 1, ExportBundleWorker.jobs.size
    assert_equal @assessment.id, ExportBundleWorker.jobs.first["args"].first
  end

  test "should destroy assessment" do
    assert_difference("Assessment.count", -1) do
      delete assessment_url(@assessment)
    end

    assert_redirected_to assessments_url
  end
end

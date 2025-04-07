require "test_helper"

class AssessmentsControllerTest < ActionDispatch::IntegrationTest
  include ActiveStorageHelpers
  include ActiveJob::TestHelper
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

  test 'should update the assessment status to "completed" and send an email if a file is present in the params' do
    attach_file_to_fixture(@assessment, :file, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    @assessment.reload
    assert_enqueued_with(
      job: ActionMailer::MailDeliveryJob,
      args: [
        "AssessmentsMailer",
        "new_analysis",
        "deliver_now",
        {args: [@assessment]}
      ],
      queue: "default"
    ) do
      patch assessment_url(@assessment), params: {assessment: {file: @assessment.file.signed_id}}
    end
    @assessment.reload
    assert_equal "completed", @assessment.status
  end

  test "should remove file when the remove_file param is true" do
    @assessment.update!(status: "completed")
    attach_file_to_fixture(@assessment, :file, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    @assessment.reload
    patch assessment_url(@assessment), params: {assessment: {remove_file: "true"}}
    @assessment.reload
    assert_equal "submitted", @assessment.status
    assert_redirected_to assessment_url(@assessment)
    assert_equal I18n.t("assessments.show.successfully_removed"), flash[:notice]
    assert_not @assessment.file.attached?
  end

  test "should download analysis file if file is attached" do
    attach_file_to_fixture(@assessment, :file, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    get download_analysis_assessment_url(@assessment)
    assert_redirected_to rails_blob_path(@assessment.file, disposition: "attachment")
  end

  test "should not download analysis file if file is not attached" do
    assert_not @assessment.file.attached?
    get download_analysis_assessment_url(@assessment)
    assert_redirected_to assessment_path(@assessment), alert: I18n.t("assessments.download_analysis.no_file")
  end

  test "should destroy assessment" do
    assert_difference("Assessment.count", -1) do
      delete assessment_url(@assessment)
    end

    assert_redirected_to assessments_url
  end
end

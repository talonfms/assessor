require "test_helper"

class AssessmentTest < ActiveSupport::TestCase
  include ActiveStorageHelpers

  setup do
    @assessment = assessments(:one)
    @assessment.include_sow_check = true
    @assessment.include_finance_check = true
  end
  test "submittable" do
    @assessment.update!(status: "in_progress")
    25.times do
      SurveyResponse.create!(responses: [responses(:one)], assessment: @assessment)
    end
    @assessment.sow_check.update!(target_files: 1)
    attach_file_to_fixture(@assessment.sow_check, :files, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    @assessment.finance_check.update!(target_files: 1)
    attach_file_to_fixture(@assessment.finance_check, :files, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    @assessment.reload
    assert @assessment.submittable?
  end
end

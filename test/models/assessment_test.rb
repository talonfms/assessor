require "test_helper"

class AssessmentTest < ActiveSupport::TestCase
  include ActiveStorageHelpers

  setup do
    @assessment = assessments(:one)
  end
  test "submittable" do
    @assessment.sow_check.update(target_files: 1)
    @assessment.finance_check.update(target_files: 1)
    SurveyCheck.create!(assessment: @assessment, target_files: 1, account: @assessment.account)
    @assessment.update!(status: "in_progress")
    SurveyResponse.create!(responses: [responses(:one)], assessment: @assessment)
    attach_file_to_fixture(@assessment.sow_check, :files, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    attach_file_to_fixture(@assessment.finance_check, :files, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    @assessment.reload
    assert @assessment.submittable?
  end

  test "at least one check present" do
    @assessment.sow_check.destroy
    @assessment.finance_check.destroy
    @assessment.survey_check.destroy
    @assessment.reload
    @assessment.save
    assert_not_empty @assessment.errors[:base]
    assert_equal I18n.t("activerecord.errors.models.assessment.no_checks"), @assessment.errors[:base].first
  end
end

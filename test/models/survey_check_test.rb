require "test_helper"

class SurveyCheckTest < ActiveSupport::TestCase
  setup do
    @account = accounts(:one)
    @assessment = assessments(:one)
    @survey_check = SurveyCheck.new(
      assessment: @assessment,
      account: @account
    )

    ActsAsTenant.current_tenant = @account
  end

  teardown do
    ActsAsTenant.current_tenant = nil
  end

  test "set_defaults sets target_files to DEFAULT_TARGET_FILES on create" do
    assert_nil @survey_check.target_files

    @survey_check.save!

    assert_equal SurveyCheck::DEFAULT_TARGET_FILES, @survey_check.target_files
  end

  test "set_defaults doesn't override target_files if already set" do
    @survey_check.save!
    custom_target = 10
    @survey_check.target_files = custom_target

    @survey_check.save!

    assert_equal custom_target, @survey_check.target_files
  end

  test "complete? returns true when survey response count meets or exceeds target_files" do
    @survey_check.save!

    SurveyCheck::DEFAULT_TARGET_FILES.times do |i|
      sr = SurveyResponse.new(
        assessment: @assessment
      )
      sr.responses = [responses(:one)]
      sr.save!
    end
    @survey_check.reload
    assert @survey_check.complete?
  end

  test "complete? returns false when survey response count is below target_files" do
    @survey_check.save!

    (SurveyCheck::DEFAULT_TARGET_FILES - 3).times do |i|
      sr = SurveyResponse.new(
        assessment: @assessment
      )
      sr.responses = [responses(:one)]
      sr.save!
    end

    @survey_check.reload
    assert_not @survey_check.complete?
  end

  test "complete? handles nil survey_responses gracefully" do
    @assessment.survey_responses.destroy_all

    survey_check = SurveyCheck.create!(
      assessment: @assessment,
      account: @account
    )

    assert_not survey_check.complete?
  end

  test "complete? works with custom target_files value" do
    @survey_check.save!
    custom_target = 3
    @survey_check.target_files = custom_target
    @survey_check.save!

    custom_target.times do |i|
      sr = SurveyResponse.new(
        assessment: @assessment
      )
      sr.responses = [responses(:one)]
      sr.save!
    end

    assert @survey_check.complete?
  end
end

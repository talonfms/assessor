require "test_helper"

class SowChecksControllerTest < ActionDispatch::IntegrationTest
  include ActiveStorageHelpers
  setup do
    sign_in_as_admin(users(:one), accounts(:one))
    @sow_check = sow_checks(:one)
  end

  test "should remove file when the remove_file param is true" do
    attach_file_to_fixture(@sow_check, :files, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    @sow_check.reload
    assert_equal @sow_check.files.attached?, true
    patch sow_check_url(@sow_check), params: {sow_check: {remove_file: "true", file_id: @sow_check.files.first.id}}
    @sow_check.reload
    assert_redirected_to assessment_url(@sow_check.assessment)
    assert_equal I18n.t("assessments.show.successfully_removed"), flash[:notice]
    assert_not @sow_check.files.attached?
  end
end

require "test_helper"

class FinanceChecksControllerTest < ActionDispatch::IntegrationTest
  include ActiveStorageHelpers
  setup do
    sign_in_as_admin(users(:one), accounts(:one))
    @finance_check = finance_checks(:one)
  end

  test "should remove file when the remove_file param is true" do
    attach_file_to_fixture(@finance_check, :files, "test/fixtures/files/test_pdf.pdf", "application/pdf")
    @finance_check.reload
    assert_equal @finance_check.files.attached?, true
    patch finance_check_url(@finance_check), params: {finance_check: {remove_file: "true", file_id: @finance_check.files.first.id}}
    @finance_check.reload
    assert_redirected_to assessment_url(@finance_check.assessment)
    assert_equal I18n.t("assessments.show.successfully_removed"), flash[:notice]
    assert_not @finance_check.files.attached?
  end
end

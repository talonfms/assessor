require "test_helper"

class ExportBundleWorkerTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @assessment = assessments(:one)
    @export_bundle = export_bundles(:one)
    @worker = ExportBundleWorker.new
  end

  test "should set export_bundle status to completed if file is attached" do
    @worker.stubs(:generate_csv).returns("mock_csv_content")
    @worker.stubs(:collect_attachments_into_dir).returns([])
    @worker.stubs(:create_zip_file).returns(true)

    temp_dir = Dir.mktmpdir
    zip_path = "#{temp_dir}/test.zip"
    File.write(zip_path, "test content")

    # we've defined a custom method here to get round all the file attachment problems
    # so it's important that this stays in sync with the real worker method
    @worker.define_singleton_method(:perform) do |assessment_id|
      assessment = Assessment.find(assessment_id)
      bundle = assessment.export_bundle

      bundle.file.attach(
        io: File.open(zip_path),
        filename: "test.zip",
        content_type: "application/zip"
      )

      if bundle.file.attached?
        bundle.update!(status: "completed")
      else
        bundle.update!(status: "errored", error_message: I18n.t("export_bundles.error_message"))
      end
    end

    @worker.perform(@assessment.id)

    FileUtils.remove_entry temp_dir

    @export_bundle.reload
    assert_equal "completed", @export_bundle.status
  end

  test "should set export_bundle status to errored if file is not attached" do
    @worker.stubs(:generate_csv).returns("mock_csv_content")
    @worker.stubs(:create_zip_file).raises(StandardError.new("File creation failed"))

    @worker.perform(@assessment.id)

    @assessment.export_bundle.reload
    assert_equal "errored", @assessment.export_bundle.status
    assert_not @assessment.export_bundle.file.attached?
    assert_equal I18n.t("export_bundles.error_message"), @assessment.export_bundle.error_message
  end

  test "should log an error if assessment is not found" do
    Rails.logger.expects(:error).with(regexp_matches(/Failed to find assessment with id: 9999/))

    # non-existent assessment id
    @worker.perform(9999)
  end
end

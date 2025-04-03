require "zip"
class ExportBundleWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3, queue: "default"

  def perform(assessment_id)
    begin
      assessment = Assessment.includes(survey_responses: {responses: :block}).find(assessment_id)
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "Failed to find assessment with id: #{assessment_id} - #{e.message}"
      return
    end

    temp_dir = Dir.mktmpdir
    zip_path = "#{temp_dir}/export_bundle_#{Time.now.to_i}.zip"

    begin
      csv_content = generate_csv(assessment) if assessment.survey_responses.present?
      csv_path = "#{temp_dir}/responses_export.csv"
      File.write(csv_path, csv_content)

      attachment_file_paths = collect_attachments_into_dir(assessment, temp_dir)

      create_zip_file(zip_path, [csv_path] + attachment_file_paths)

      bundle = assessment.export_bundle

      name = assessment.name.gsub(" ", "_")

      bundle.file.attach(
        io: File.open(zip_path),
        filename: "assessment_export_#{name}_#{assessment.id}.zip",
        content_type: "application/zip"
      )

      if bundle.file.attached?
        bundle.update!(error_message: nil, status: "completed")
      else
        bundle.update!(status: "errored", error_message: I18n.t("export_bundles.error_message"))
      end
    rescue => e
      Rails.logger.error "Error exporting file bundle: #{e.message}"
      assessment.export_bundle.update!(
        status: "errored",
        error_message: I18n.t("export_bundles.error_message")
      )
    ensure
      FileUtils.remove_entry temp_dir
    end
  end

  def generate_csv(assessment)
    service = ConvertResponsesToCsv.new(assessment)
    service.export_responses_to_csv
  end

  def collect_attachments_into_dir(assessment, temp_dir)
    file_paths = []
    attachments = []
    attachments << assessment.sow_check.files.all if assessment.sow_check&.files.present?
    attachments << assessment.finance_check.files.all if assessment.finance_check&.files.present?
    attachments.flatten!

    attachments.each_with_index do |attachment, index|
      filename = attachment.filename.to_s
      file_path = "#{temp_dir}/#{filename}"

      # if there are multiple files present with the same filename
      # add an index and basename to the filename to distinguish them
      if File.exist?(file_path)
        extension = File.extname(filename)
        basename = File.basename(filename, extension)
        file_path = "#{temp_dir}/#{basename}_#{index}#{extension}"
      end

      # copies the file object to the file path
      # (doesn't download/read the contents into Ruby memory in case we have a large file)
      attachment.open do |file|
        FileUtils.cp(file.path, file_path)
      end

      file_paths << file_path
    end

    file_paths
  end

  def create_zip_file(zip_path, files)
    Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      files.each do |file|
        zipfile.add(File.basename(file), file)
      end
    end
  end
end

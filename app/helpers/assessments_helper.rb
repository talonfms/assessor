module AssessmentsHelper
  def assessment_label(assessment, classes: nil)
    case assessment.status
    when "completed"
      type = :success
    when "submitted"
      type = :warning
    when "in_progress"
      type = :info
    end
    render LabelComponent.new(text: assessment.translated_status, type: type, classes: classes)
  end
end

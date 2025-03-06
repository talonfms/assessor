module AssessmentsHelper
  def assessment_label(assessment, classes: nil)
    type = assessment.completed? ? :success : :info
    render LabelComponent.new(text: assessment.translated_status, type: type, classes: classes)
  end
end

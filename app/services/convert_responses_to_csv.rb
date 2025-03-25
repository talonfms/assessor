require "csv"

class ConvertResponsesToCsv
  def initialize(assessment)
    @assessment = assessment
  end

  def export_responses_to_csv
    CSV.generate(headers: true) do |csv|
      csv << generate_headers

      @assessment.survey_responses.each do |sr|
        csv << generate_row_data(sr)
      end
    end
  end

  def generate_headers
    responses = filtered_responses(@assessment.survey_responses.first)
    headers_array = ["Name", "Email", "Submitted On"]
    responses.each do |r|
      headers_array << r.block.question
    end

    headers_array
  end

  def generate_row_data(sr)
    row_data = [
      extract_name_from_survey_response(sr),
      extract_email_from_survey_response(sr),
      sr.created_at
    ]
    filtered_responses(sr).each do |r|
      row_data << extract_answer_from_response_data(r.response_data)
    end

    row_data
  end

  def extract_answer_from_response_data(response_data)
    case response_data&.keys&.first
    when "text"
      response_data["text"]
    when "block_option_id"
      BlockOption.find(response_data["block_option_id"]).key
    when nil
      ""
    end
  end

  def extract_name_from_survey_response(sr)
    return sr.respondent&.name if sr.respondent.present?

    sr.responses.find_by(block_id: Block.find_by(question: "Full Name:")&.id)&.response_data&.[]("text")
  end

  def extract_email_from_survey_response(sr)
    return sr.respondent_email if sr.respondent_email.present?

    sr.responses.find_by(block_id: Block.find_by(question: "Email:")&.id)&.response_data&.[]("text")
  end

  def filtered_responses(sr)
    excluded_question_blocks = ["Email:", "Full Name:"]
    sr.responses.reject { |response| excluded_question_blocks.include?(response.block.question) }
  end
end

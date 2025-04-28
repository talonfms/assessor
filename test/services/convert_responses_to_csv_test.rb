require "test_helper"
require "csv"

class ConvertResponsesToCsvTest < ActiveSupport::TestCase
  fixtures :assessments, :survey_responses, :responses, :blocks, :block_options

  def setup
    @assessment = assessments(:one)
    template_version_two = template_versions(:two)
    survey_response_two = survey_responses(:two)
    # ensure that the csv generator retrieves the correct name and email blocks
    block_1 = Block.create!(question: "Full Name:", block_type: "short_text", template_version: template_version_two)
    block_2 = Block.create!(question: "Email:", block_type: "short_text", template_version: template_version_two)
    Response.create!(survey_response: survey_response_two, block: block_1, response_data: {"text" => "wrong-name@example.com"})
    Response.create!(survey_response: survey_response_two, block: block_2, response_data: {"text" => "WRONG NAME"})
  end

  test "should generate CSV string with respondent and respondent_email present" do
    survey_response = @assessment.survey_responses.first

    csv_string = ConvertResponsesToCsv.new(@assessment).export_responses_to_csv
    csv = CSV.parse(csv_string, headers: true)

    assert_equal ["Name", "Email", "Submitted On", "Some Question", "Alternative Question"], csv.headers
    assert_equal survey_response.respondent.name, csv[0]["Name"]
    assert_equal survey_response.respondent_email, csv[0]["Email"]
    assert_equal "My name is Sean Paul", csv[0]["Some Question"]
    assert_equal "Option 1", csv[0]["Alternative Question"]
  end

  test "should generate CSV string without respondent and respondent_email but with Email and Full Name blocks" do
    survey_response = @assessment.survey_responses.first
    survey_response.respondent = nil
    survey_response.respondent_email = nil
    survey_response.save!
    block_1 = Block.create!(template_version: @assessment.template_version, question: "Email:", block_type: "short_text")
    block_2 = Block.create!(template_version: @assessment.template_version, question: "Full Name:", block_type: "short_text")
    Response.create!(survey_response: survey_response, block: block_1, response_data: {"text" => "anonymous-user@example.com"})
    Response.create!(survey_response: survey_response, block: block_2, response_data: {"text" => "Anonymous User"})

    csv_string = ConvertResponsesToCsv.new(@assessment).export_responses_to_csv
    csv = CSV.parse(csv_string, headers: true)

    assert_equal ["Name", "Email", "Submitted On", "Some Question", "Alternative Question"], csv.headers
    assert_equal "Anonymous User", csv[0]["Name"]
    assert_equal "anonymous-user@example.com", csv[0]["Email"]
  end
end

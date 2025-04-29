class SuggestedSurveyGenerator
  def generate(account_id)
    question_array = ["What processes for worker classification are in place?",
      "Do you have a process in place to identify worker misclassification risks?",
      "Does your organisation have worker classification policies and guidelines?",
      "Do you have access to training on worker classification policies?", "Do you leverage technology to support in worker classification?",
      "Do you conduct audits on worker classification?",
      "Do you have regulartory awareness with the usage of SOW engagements?",
      "Do you have a risk management framework for SOW engagements?",
      "Do you have a supplier risk assessment process?",
      "Do you have compliance monitoring in place for SOW engagements?",
      "Do you have data security and privacy compliance processes in place?",
      "Do have a clear definition of requirements (scope) when creating SOW engagements?",
      "Do you have supplier performance management tracking in place?",
      "Do you track on-time delivery of services engaged under a SOW?",
      "Do you have a quality assurance process in place for procuring services?",
      "Do you conduct enagement manager satisfaction surerys?",
      "Do you have technology in place for quality monitoring?",
      "Do you have a continuous improvement program in place with services suppliers?",
      "Do you have visibility into services total spend?",
      "Do you have cost benchmarking in place?",
      "Do you have budgeting and cost control processes in place?",
      "Do you have cost reduction initiatives in place?",
      "Do you have technology in place for cost  management of procuring services?",
      "Do you have supplier cost transparency?",
      "Have you standardised  services procurement processes?",
      "Are you using technology to drive automation?",
      "Do you track services procurement cycle times?",
      "Do you have a supplier onboarding process?",
      "Do you have collaboration across teams when procuring services?",
      "Have you run a supplier rationalization process?",
      "Do you have real-time reporting and analytics related to your service procurement spend?"]
    Account.where(id: account_id).each do |account|
      st = SurveyTemplate.create!(name: "Suggested Survey Questions", description: "A starting point with some example questions that you may want to include in a survey", account: account)
      tv = TemplateVersion.create!(survey_template: st, version_number: 1, notes: "Initial version", created_by: User.first)
      question_array.each_with_index do |question, index|
        Block.create!(template_version: tv, block_type: "short_text", question: question, position: index + 1, config: {"required" => "0", "max_length" => "100", "min_length" => "0", "button_text" => "Next", "description" => "", "placeholder" => ""})
      end
    end
  end
end

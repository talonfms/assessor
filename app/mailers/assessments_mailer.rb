class AssessmentsMailer < BaseMailer
  def new_analysis(assessment)
    @assessment = assessment
    mail to: "recipient@MYDOMAIN.com", subject: "Success! You did it."
  end
end

class AssessmentsMailer < BaseMailer
  def new_analysis(assessment)
    @assessment = assessment
    @assessment.account.members.each do |member|
      mail to: member.user.email, subject: I18n.t("mailers.assessments_mailer.new_analysis.subject")
    end
  end
end

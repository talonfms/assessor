class SurveyCheck < ApplicationRecord
  belongs_to :assessment
  belongs_to :account
  acts_as_tenant :account

  DEFAULT_TARGET_FILES = 5

  before_create :set_defaults

  def complete?
    assessment.survey_responses&.count&.>= target_files || DEFAULT_TARGET_FILES
  end

  def set_defaults
    self.target_files = DEFAULT_TARGET_FILES
  end
end

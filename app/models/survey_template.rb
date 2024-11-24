class SurveyTemplate < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  has_many :template_versions
  has_many :assessments, through: :template_versions
end

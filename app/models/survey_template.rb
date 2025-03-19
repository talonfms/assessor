class SurveyTemplate < ApplicationRecord
  broadcasts_refreshes
  belongs_to :account
  has_many :template_versions, dependent: :destroy
  has_many :assessments, through: :template_versions

  def latest_version
    template_versions.order(version_number: :desc).first
  end
end

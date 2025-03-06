class Assessment < ApplicationRecord
  include TranslateEnum

  broadcasts_refreshes
  acts_as_tenant :account
  belongs_to :account
  belongs_to :template_version
  has_one :sow_check, dependent: :destroy
  has_one :finance_check, dependent: :destroy
  has_many :survey_responses, dependent: :destroy

  enum :status, %w[in_progress submitted completed].index_by(&:itself)
  translate_enum :status

  has_secure_token

  attr_accessor :include_sow_check, :include_finance_check

  def submittable?
    in_progress? && sow_check&.complete? && finance_check&.complete?
  end
end

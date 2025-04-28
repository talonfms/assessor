class Assessment < ApplicationRecord
  include TranslateEnum

  broadcasts_refreshes
  acts_as_tenant :account
  belongs_to :account
  belongs_to :template_version, optional: true
  has_one :sow_check, dependent: :destroy
  has_one :finance_check, dependent: :destroy
  has_one :survey_check, dependent: :destroy
  has_many :survey_responses, dependent: :destroy
  has_one :export_bundle, dependent: :destroy
  has_one_attached :file

  validates :name, presence: true
  validate :at_least_one_check_present

  enum :status, %w[in_progress submitted completed].index_by(&:itself)
  translate_enum :status

  has_secure_token

  attr_accessor :include_sow_check, :include_finance_check

  def submittable?
    in_progress? &&
      (survey_check.nil? || survey_check.complete?) &&
      (sow_check.nil? || sow_check.complete?) &&
      (finance_check.nil? || finance_check.complete?)
  end

  def at_least_one_check_present
    if survey_check.nil? && sow_check.nil? && finance_check.nil?
      errors.add(:base, message: I18n.t("activerecord.errors.models.assessment.no_checks"))
    end
  end
end

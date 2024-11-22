class Assessment < ApplicationRecord
  include TranslateEnum

  broadcasts_refreshes
  acts_as_tenant :account
  belongs_to :account
  has_one :sow_check, dependent: :destroy

  enum :status, %w[in_progress completed].index_by(&:itself)
  translate_enum :status

  attr_accessor :include_sow_check
end

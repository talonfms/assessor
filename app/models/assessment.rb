class Assessment < ApplicationRecord
  include TranslateEnum

  broadcasts_refreshes
  acts_as_tenant :account
  belongs_to :account

  enum :status, %w[in_progress completed].index_by(&:itself)
  translate_enum :status
end

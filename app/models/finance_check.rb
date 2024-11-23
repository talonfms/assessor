class FinanceCheck < ApplicationRecord
  belongs_to :assessment
  belongs_to :account
  has_many_attached :files

  acts_as_tenant :account

  DEFAULT_TARGET_FILES = 1

  before_create :set_defaults

  def complete?
    files.count >= (target_files || DEFAULT_TARGET_FILES)
  end

  def set_defaults
    self.target_files = DEFAULT_TARGET_FILES
  end
end

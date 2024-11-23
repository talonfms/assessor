class SowCheck < ApplicationRecord
  belongs_to :assessment
  belongs_to :account
  has_many_attached :files

  acts_as_tenant :account

  def complete?
    files.count >= target_files
  end
end

class SowCheck < ApplicationRecord
  belongs_to :assessment
  belongs_to :account
  has_many_attached :files

  acts_as_tenant :account
end

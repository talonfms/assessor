class ExportBundle < ApplicationRecord
  belongs_to :assessment

  has_one_attached :file

  validates :status, presence: true
  enum(:status, {pending: 0, completed: 1, errored: 2})
end

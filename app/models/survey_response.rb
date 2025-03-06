class SurveyResponse < ApplicationRecord
  belongs_to :assessment

  has_many :responses, dependent: :destroy

  accepts_nested_attributes_for :responses

  validates :responses, presence: true
end

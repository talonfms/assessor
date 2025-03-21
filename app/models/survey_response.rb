class SurveyResponse < ApplicationRecord
  belongs_to :assessment
  belongs_to :respondent, class_name: "User", optional: true

  has_many :responses, dependent: :destroy

  accepts_nested_attributes_for :responses

  validates :responses, presence: true
end

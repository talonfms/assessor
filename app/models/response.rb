class Response < ApplicationRecord
  belongs_to :block
  belongs_to :survey_response
end

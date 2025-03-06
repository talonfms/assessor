class BlockGroup < ApplicationRecord
  belongs_to :template_version
  has_many :blocks

  validates :name, presence: true
  validates :template_version, presence: true

  positioned on: :template_version
end

class BlockOption < ApplicationRecord
  belongs_to :block
  before_create :set_defaults
  positioned on: :block

  def set_defaults
    position ||= 1
    name ||= "Option #{block.block_options.count + 1}"
  end
end

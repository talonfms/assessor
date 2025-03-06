class AddBlockGroupIdToBlocks < ActiveRecord::Migration[8.0]
  def change
    add_reference :blocks, :block_group, null: true, foreign_key: true
  end
end

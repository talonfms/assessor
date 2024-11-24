class CreateBlockOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :block_options do |t|
      t.references :block, null: false, foreign_key: true
      t.string :key
      t.string :value
      t.integer :position

      t.timestamps
    end
  end
end

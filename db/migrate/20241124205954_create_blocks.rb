class CreateBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :blocks do |t|
      t.references :template_version, null: false, foreign_key: true
      t.integer :block_type
      t.string :question
      t.integer :position
      t.jsonb :config

      t.timestamps
    end
  end
end

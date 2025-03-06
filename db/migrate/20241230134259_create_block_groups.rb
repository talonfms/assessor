class CreateBlockGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :block_groups do |t|
      t.string :name
      t.text :description
      t.references :template_version, null: false, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end

class CreateExportBundles < ActiveRecord::Migration[8.0]
  def change
    create_table :export_bundles do |t|
      t.references :assessment, null: false, foreign_key: true
      t.integer :status, default: 0
      t.text :error_message
      t.timestamps
    end
  end
end

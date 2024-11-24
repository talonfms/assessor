class CreateTemplateVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :template_versions do |t|
      t.references :survey_template, null: false, foreign_key: true
      t.integer :version_number
      t.datetime :locked_at
      t.text :notes
      t.references :created_by, foreign_key: {to_table: :users}

      t.timestamps
    end
  end
end

class CreateSurveyChecks < ActiveRecord::Migration[8.0]
  def change
    create_table :survey_checks do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.integer :status
      t.integer :min_required_files
      t.integer :target_files

      t.timestamps
    end
  end
end

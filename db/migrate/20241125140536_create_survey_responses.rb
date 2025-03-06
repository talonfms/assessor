class CreateSurveyResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :survey_responses do |t|
      t.references :assessment, null: false, foreign_key: true
      t.references :respondent, null: true, foreign_key: {to_table: :users}
      t.string :respondent_email
      t.datetime :completed_at

      t.timestamps
    end
  end
end

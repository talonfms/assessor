class CreateSurveyTemplates < ActiveRecord::Migration[8.0]
  def change
    create_table :survey_templates do |t|
      t.string :name
      t.text :description
      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end

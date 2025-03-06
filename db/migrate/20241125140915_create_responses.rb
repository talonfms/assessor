class CreateResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :responses do |t|
      t.references :block, null: false, foreign_key: true
      t.references :survey_response, null: false, foreign_key: true
      t.jsonb :response_data

      t.timestamps
    end
  end
end

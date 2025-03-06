class AddTokenToAssessments < ActiveRecord::Migration[8.0]
  def change
    add_column :assessments, :token, :string
  end
end

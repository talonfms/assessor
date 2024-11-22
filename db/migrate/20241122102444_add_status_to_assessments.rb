class AddStatusToAssessments < ActiveRecord::Migration[8.0]
  def change
    add_column :assessments, :status, :string, default: "in_progress"
  end
end

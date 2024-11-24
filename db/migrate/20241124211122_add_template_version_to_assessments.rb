class AddTemplateVersionToAssessments < ActiveRecord::Migration[8.0]
  def change
    add_reference :assessments, :template_version, null: false, foreign_key: true
  end
end

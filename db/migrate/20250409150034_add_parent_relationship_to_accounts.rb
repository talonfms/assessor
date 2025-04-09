class AddParentRelationshipToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_reference :accounts, :parent_account, foreign_key: {to_table: :accounts}
    add_column :accounts, :is_parent, :boolean, default: false
  end
end

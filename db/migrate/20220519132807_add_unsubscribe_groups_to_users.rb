class AddUnsubscribeGroupsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :unsubscribe_email_groups, :jsonb, default: [], null: false
  end
end

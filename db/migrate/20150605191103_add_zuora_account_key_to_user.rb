class AddZuoraAccountKeyToUser < ActiveRecord::Migration

  def change
    add_column :users, :zuora_account_key, :string
  end

end

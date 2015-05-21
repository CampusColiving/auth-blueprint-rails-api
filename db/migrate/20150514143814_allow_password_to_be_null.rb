class AllowPasswordToBeNull < ActiveRecord::Migration

  def change
    change_column :logins, :password_digest, :string, null: true
  end

end

class AddVerifiedAtToLogin < ActiveRecord::Migration

  def change
    add_column :logins, :verified_at, :datetime
  end

end

class AddFacebookUid < ActiveRecord::Migration

  def change
    add_column :logins, :facebook_uid, :string
  end

end

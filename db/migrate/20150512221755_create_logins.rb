class CreateLogins < ActiveRecord::Migration

  def change
    create_table :logins do |t|
      t.string :email,           null: false
      t.string :password_digest, null: false
      t.string :oauth2_token,    null: false

      t.timestamps
    end
  end

end

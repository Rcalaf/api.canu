class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :token
      t.string :salt
      t.string :first_name
      t.string :last_name
      t.string :user_name
      t.string :password
      t.string :email
      t.boolean :active
    end
  end
end

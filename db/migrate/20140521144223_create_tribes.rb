class CreateTribes < ActiveRecord::Migration
  def change
    create_table :tribes do |t|
      t.integer :user_id
      t.integer :friend_id

      t.timestamps
    end
  end
end

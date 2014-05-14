class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :activity_id
      t.integer :user_id
      t.integer :type
      t.string :attribute_3_4
      t.string :attribute_5

      t.timestamps
    end
  end
end

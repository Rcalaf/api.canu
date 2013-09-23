class CreateActivityNotifications < ActiveRecord::Migration
  def change
    create_table :activity_notifications do |t|
      t.integer :device_id, :null => false
      t.integer :errors_nb, :default => 0
      t.datetime :sent_at
      t.string :notification_type
      t.integer :activity_id, :null => false
      t.timestamps
    end
    add_index :activity_notifications, :device_id
    add_index :activity_notifications, :activity_id
  end
end

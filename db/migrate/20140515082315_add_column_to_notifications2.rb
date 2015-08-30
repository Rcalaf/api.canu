class AddColumnToNotifications2 < ActiveRecord::Migration
  def change
  	add_column :notifications, :attribute_8, :string
  end
end

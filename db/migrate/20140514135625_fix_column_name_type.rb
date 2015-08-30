class FixColumnNameType < ActiveRecord::Migration
  def change
    rename_column :notifications, :type, :type_notifications
  end
end

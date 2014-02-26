class AddPrivateLocationToActivities < ActiveRecord::Migration
  def change
  	add_column :activities, :private_location, :boolean, :default => false
  end
end

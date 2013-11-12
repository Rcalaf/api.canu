class AddLatitudeLongitudeToUser < ActiveRecord::Migration
  def change
    add_column :users, :latitude, :double
    add_column :users, :longitude, :double
  end
end

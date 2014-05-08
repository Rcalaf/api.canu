class AddNamePlaceToActivity < ActiveRecord::Migration
  def change
  	add_column :activities, :place_name, :string
  end
end

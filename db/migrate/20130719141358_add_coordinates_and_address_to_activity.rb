class AddCoordinatesAndAddressToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :latitude, :float
    add_column :activities, :longitude, :float
    add_column :activities, :address, :string
  end
end

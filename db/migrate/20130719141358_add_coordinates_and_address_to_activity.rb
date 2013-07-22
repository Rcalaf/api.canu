class AddCoordinatesAndAddressToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :latitude, :float
    add_column :activities, :longitude, :float
    add_column :activities, :street, :string
    add_column :activities, :city, :string
    add_column :activities, :zip_code, :string
    add_column :activities, :country, :string
  end
end

class Activity < ActiveRecord::Base
  attr_accessible :description, :length, :start, :title, :user_id, :city, :street, :zip_code, :country, :latitude, :longitude
  
  belongs_to :user 
end

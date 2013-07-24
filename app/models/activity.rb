class Activity < ActiveRecord::Base
  attr_accessible :description, :length, :start, :title, :user_id, :city, :street, :zip_code, :country, :latitude, :longitude, :image
  
  belongs_to :user 
  
  has_and_belongs_to_many :assistents,
                          class_name: "User",
                          join_table: "activities_users", 
                          association_foreign_key: "user_id", 
                          foreign_key: "activity_id"
  
  
  has_attached_file :image, 
                     #:styles => { :small => "265x"},
                     :url  => "/assets/:id/:basename.:extension",
                     :path => ":rails_root/public/assets/:id/:basename.:extension",
                     :convert_options => {:all => ["-strip", "-colorspace RGB"]}
end

class Activity < ActiveRecord::Base
  RANGE = (30*0.01)
  
  attr_accessible :description, :length, :start, :end_date, :title, :user_id, :city, :street, :zip_code, :country, :latitude, :longitude, :image
  
  before_save :set_end_date
  
  default_scope order 'start ASC'
  
  scope :active, lambda{ |end_date| where('end_date > ?', end_date) }
  scope :in_range, (lambda do |latitude,longitude|  
    latitude_range_up = latitude + Activity::RANGE
    latitude_range_down = latitude - Activity::RANGE
    longitude_range_up = longitude + Activity::RANGE
    longitude_range_down = longitude - Activity::RANGE   
    where('latitude < ? AND latitude > ? AND longitude < ? AND longitude > ?',latitude_range_up,latitude_range_down,longitude_range_up,longitude_range_down) 
    end)

  
  belongs_to :user 
  
  has_and_belongs_to_many :attendees,
                          class_name: "User",
                          join_table: "activities_users", 
                          association_foreign_key: "user_id", 
                          foreign_key: "activity_id"
                         
  
  
  has_attached_file :image, 
                     #:styles => { :small => "265x"},
                     :url  => "/system/:id/:class/:basename.:extension",
                     :path => ":rails_root/public/system/:id/:class/:basename.:extension",
                     :convert_options => {:all => ["-strip", "-colorspace RGB"]}
                    
  
  private 
  
  def set_end_date
    self.end_date = self.start + (self.length.hour * 60 * 60 + self.length.min * 60 + self.length.sec)
  end
end

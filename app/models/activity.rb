class Activity < ActiveRecord::Base
  #0.01	--> 1.1132 km * 30 =  33.396 km
  RANGE = (100*0.01)
  
  attr_accessible :description, :length, :start, :end_date, :title, :user_id, :city, :street, :zip_code, :country, :latitude, :longitude, :image
  before_save :set_end_date
  before_update :send_edited_notification
  after_create :send_created_notification
  before_destroy :send_deleted_notificaiton

  default_scope order 'start ASC'
  
  scope :active, lambda{ |end_date| where('end_date > ?', end_date) }
  scope :in_range_2, (lambda do |latitude,longitude|  
    latitude_range_up = latitude + Activity::RANGE
    latitude_range_down = latitude - Activity::RANGE
    longitude_range_up = longitude + Activity::RANGE
    longitude_range_down = longitude - Activity::RANGE   
    where('latitude < ? AND latitude > ? AND longitude < ? AND longitude > ?',latitude_range_up,latitude_range_down,longitude_range_up,longitude_range_down) 
    end)
    
  scope :in_range, select('*')
  
  scope :to_be_remind, lambda{ |time| where('start <= ? && end_date > ?', time + 30*60, time) }
  
  belongs_to :user 
  has_many :activity_notifications, dependent: :destroy
  
  has_and_belongs_to_many :attendees,
                          class_name: "User",
                          join_table: "activities_users", 
                          association_foreign_key: "user_id", 
                          foreign_key: "activity_id"
  
  has_many :messages, order: "created_at asc", dependent: :destroy
  
  has_attached_file :image, 
                     #:styles => { :small => "265x"},
                     :url  => "/system/:id/:class/:basename.:extension",
                     :path => ":rails_root/public/system/:id/:class/:basename.:extension",
                     :convert_options => {:all => ["-strip", "-colorspace RGB"]}
  
  validates :title, :presence => true         
  
  private 
  
  def send_edited_notification
    notifications = []
    self.attendees.each do |user|
      user.devices.each do |device| 
         device.update_attribute(:badge,device.badge.to_i + 1)
         notifications << APNS::Notification.new(device.token,{:alert => "The activity \"#{self.title}\" that you are attending has been updated!",:badge => device.badge,:sound => 'default'})
      end
    end
    APNS.send_notifications(notifications) unless notifications.empty?
  end
  
  def send_created_notification
    notifications = []
    User.in_range(self.latitude,self.longitude).each do |user|
      user.devices.each do |device| 
         device.update_attribute(:badge,device.badge.to_i + 1)
         notifications << APNS::Notification.new(device.token,{:alert => "The activity \"#{self.title}\" has been created on #{self.start.strftime('%b %d')} at #{self.start.strftime('%H:%M')}",:badge => device.badge,:sound => 'default'})
      end
    end
    APNS.send_notifications(notifications) unless notifications.empty?
  end
  
  def send_deleted_notificaiton
    notifications = []
    self.attendees.each do |user|
      user.devices.each do |device| 
         device.update_attribute(:badge,device.badge.to_i + 1)
         notifications << APNS::Notification.new(device.token,{:alert => "The activity \"#{self.title}\" that you would attend has been deleted!",:badge => device.badge,:sound => 'default'})
      end
    end
    APNS.send_notifications(notifications) unless notifications.empty?
  end
  
  
  
  def set_end_date
    self.end_date = self.start + (self.length.hour * 60 * 60 + self.length.min * 60 + self.length.sec)
  end
end

class Activity < ActiveRecord::Base
  #0.01	--> 1.1132 km * 30 =  33.396 km
  RANGE = (100*0.01)
  
  attr_accessible :description, :length, :start, :end_date, :title, :user_id, :city, :street, :zip_code, :country, :latitude, :longitude, :private_location, :invitation_token
  before_save :set_end_date
  before_update :send_edited_notification
  # after_create :send_created_notification
  before_destroy :send_deleted_notificaiton
  before_create :set_invitation_token
  

  default_scope order 'start ASC'
  
  scope :active, lambda{ |end_date| where('end_date > ?', end_date) }
  scope :in_range, (lambda do |latitude,longitude|  
    latitude_range_up = latitude + Activity::RANGE
    latitude_range_down = latitude - Activity::RANGE
    longitude_range_up = longitude + Activity::RANGE
    longitude_range_down = longitude - Activity::RANGE   
    where('latitude < ? AND latitude > ? AND longitude < ? AND longitude > ?',latitude_range_up,latitude_range_down,longitude_range_up,longitude_range_down) 
    end)
    
  scope :in_range_2, select('*')
  
  scope :to_be_remind, lambda{ |time| where('start <= ? && end_date > ?', time + 30*60, time) }

  scope :privacy_location, lambda{ |private_location| 
    if private_location
      where('private_location = ?', private_location) 
    else
      where('private_location = ? OR private_location is NULL', private_location)
    end
  }
  
  belongs_to :user 
  has_many :activity_notifications, dependent: :destroy
  
  has_and_belongs_to_many :attendees,
                          class_name: "User",
                          join_table: "activities_users", 
                          association_foreign_key: "user_id", 
                          foreign_key: "activity_id"
  
  has_many :messages, order: "created_at asc", dependent: :destroy

  has_many :invitation_lists, dependent: :destroy
  
  validates :title, :presence => true  

  def self.send_created_notification(activity)
    notifications = []
    # if you are around the event

    if !activity.private_location
      User.in_range(activity.latitude,activity.longitude).each do |user|
        puts user
        userAlreadyInvited = false
        activity.invitation_lists.each do |invitation_list|
          invitation_list.attendees_invitation.each do |userinvit|
            if user != userinvit
              userAlreadyInvited = true
            end
          end
        end
        if !userAlreadyInvited
          count = Counter.find_by_user_id(user.id)
          if count
            if count.unlock
              user.devices.each do |device| 
                device.update_attribute(:badge,device.badge.to_i + 1)
                notifications << APNS::Notification.new(device.token,{:alert => "The activity \"#{activity.title}\" has been created on #{activity.start.strftime('%b %d')} at #{activity.start.strftime('%H:%M')}",:badge => device.badge,:sound => 'default',:other => {info: {id: activity.id, type: 'create activity'}}})
              end
            end
          end
        end
      end
    end
    
    #if you are invited
    activity.invitation_lists.each do |invitation_list|
      invitation_list.attendees_invitation.each do |user|
        user.devices.each do |device| 
          device.update_attribute(:badge,device.badge.to_i + 1)
          notifications << APNS::Notification.new(device.token,{:alert => "You are invited to \"#{activity.title}\" on #{activity.start.strftime('%b %d')} at #{activity.start.strftime('%H:%M')}",:badge => device.badge,:sound => 'default',:other => {info: {id: activity.id, type: 'create activity'}}})
        end
      end
    end
    APNS.send_notifications(notifications) unless notifications.empty?
  end       
  
  private 
  
  def set_invitation_token
    begin 
      self.invitation_token = SecureRandom.hex(9)
    end while self.class.exists?(invitation_token: invitation_token)
  end
  
  def send_edited_notification
    notifications = []
    self.attendees.each do |user|
      user.devices.each do |device| 
         device.update_attribute(:badge,device.badge.to_i + 1)
         notifications << APNS::Notification.new(device.token,{:alert => "The activity \"#{self.title}\" that you are attending has been updated!",:badge => device.badge,:sound => 'default',:other => {info: {id: self.id, type: 'edit activity'}}})
      end
    end
    APNS.send_notifications(notifications) unless notifications.empty?
  end
  
  def send_deleted_notificaiton
    notifications = []
    self.attendees.each do |user|
      user.devices.each do |device| 
         device.update_attribute(:badge,device.badge.to_i + 1)
         notifications << APNS::Notification.new(device.token,{:alert => "The activity \"#{self.title}\" that you would attend has been deleted!",:badge => device.badge,:sound => 'default',:other => {info: {id: self.id, type: 'delete activity'}}})
      end
    end
    APNS.send_notifications(notifications) unless notifications.empty?
  end
  
  
  
  def set_end_date
    self.end_date = self.start + (self.length.hour * 60 * 60 + self.length.min * 60 + self.length.sec)
  end
end

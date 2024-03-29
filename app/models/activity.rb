class Activity < ActiveRecord::Base
  #0.01	--> 1.1132 km * 30 =  33.396 km
  RANGE = (100*0.01)
  
  attr_accessible :description, :length, :start, :end_date, :title, :user_id, :city, :street, :zip_code, :country, :latitude, :longitude, :private_location, :invitation_token, :place_name
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
  # has_many :activity_notifications, dependent: :destroy
  
  has_and_belongs_to_many :attendees,
                          class_name: "User",
                          join_table: "activities_users", 
                          association_foreign_key: "user_id", 
                          foreign_key: "activity_id"
  
  has_many :messages, order: "created_at asc", dependent: :destroy

  has_many :invitation_lists, dependent: :destroy

  has_many :notifications, dependent: :destroy
  
  validates :title, :presence => true  

  def self.send_created_notification(activity)

    # if you are around the event

    puts "Create activity"

    name = ""

    if activity.user.first_name.blank?
      name = activity.user.user_name
    else
      name = activity.user.first_name
    end

    if !activity.private_location
      User.in_range(activity.latitude,activity.longitude).each do |user|
        userAlreadyInvited = false
        activity.invitation_lists.each do |invitation_list|
          invitation_list.attendees_invitation.each do |userinvit|
            if user != userinvit
              userAlreadyInvited = true
            end
          end
        end
        if !userAlreadyInvited

          if activity.user != user
            notification = Notification.new
            notification.activity = activity
            notification.user = user
            notification.type_notifications = 2
            notification.save()

            Thread.new do
              puts "Arund you"
              user.devices.each do |device| 
                device.update_attribute(:badge,device.badge.to_i + 1)
                APNS.send_notification(device.token,{:alert => "The activity \"#{activity.title}\" has been created on #{activity.start.strftime('%b %d')} at #{activity.start.strftime('%H:%M')}",:badge => device.badge,:sound => 'default',:other => {info: {id: activity.id, type: 'create activity around'}}})
              end
            end
          end
        end
      end
    end
    
    #if you are invited
    activity.invitation_lists.each do |invitation_list|
      invitation_list.attendees_invitation.each do |user|

        puts "Create activity notification"

        notification = Notification.new
        notification.activity = activity
        notification.user = user
        notification.type_notifications = 1
        notification.save()

        Thread.new do
          user.devices.each do |device| 
            device.update_attribute(:badge,device.badge.to_i + 1)
            APNS.send_notification(device.token,{:alert => "#{name} invited you to #{activity.title}",:badge => device.badge,:sound => 'default',:other => {info: {id: activity.id, type: 'create activity invit'}}})
          end
        end
      end
    end
  end

  def self.send_new_people_notification(activity,new_peoples)
    #if you are invited

    name = ""

    if activity.user.first_name.blank?
      name = activity.user.user_name
    else
      name = activity.user.first_name
    end

    new_peoples.each do |user|

      notification = Notification.new
      notification.activity = activity
      notification.user = user
      notification.type_notifications = 1
      notification.save()

      Thread.new do
        user.devices.each do |device| 
          device.update_attribute(:badge,device.badge.to_i + 1)
          APNS.send_notification(device.token,{:alert => "#{name} invited you to #{activity.title}",:badge => device.badge,:sound => 'default',:other => {info: {id: activity.id, type: 'create activity invit'}}})
        end
      end 
    end

  end

  def self.send_new_invit_notification(activity,new_user)
    name = ""

    if new_user.first_name.blank?
      name = new_user.user_name
    else
      name = new_user.first_name
    end
     activity.attendees.each do |user|

      notification = Notification.new
      notification.activity = activity
      notification.user = user
      notification.type_notifications = 3
      notification.attribute_3_4 = name
      notification.save()

      Thread.new do
        user.devices.each do |device| 
           device.update_attribute(:badge,device.badge.to_i + 1)
           APNS.send_notification(device.token,{:alert => "#{name} is going to #{activity.title}",:badge => device.badge,:sound => 'default',:other => {info: {id: activity.id, type: 'new invit'}}})
        end
      end
    end
  end 

  def self.send_remove_invit_notification(activity,remove_user)

    name = ""

    if remove_user.first_name.blank?
      name = remove_user.user_name
    else
      name = remove_user.first_name
    end
     activity.attendees.each do |user|

      notification = Notification.new
      notification.activity = activity
      notification.user = user
      notification.type_notifications = 4
      notification.attribute_3_4 = name
      notification.save()

      Thread.new do
        user.devices.each do |device| 
           device.update_attribute(:badge,device.badge.to_i + 1)
           APNS.send_notification(device.token,{:alert => "#{name} is no longer going to #{activity.title}",:badge => device.badge,:sound => 'default',:other => {info: {id: activity.id, type: 'remove invit'}}})
        end
      end
    end
  end   
  
  private 
  
  def set_invitation_token
    begin 
      self.invitation_token = SecureRandom.hex(4)
    end while self.class.exists?(invitation_token: invitation_token)
  end
  
  def send_edited_notification

    if self.changed?

      notOnlyDescriptionChanged = false

      text = ""

      if self.title_changed?
        text = text + "#{self.title_was} is now #{self.title} "
        notOnlyDescriptionChanged = true
      else
        text = text + "#{self.title} is now "
      end

      if self.start_changed?
        text = text + "at #{self.start.strftime('%H:%M')} #{self.start.strftime('%b %d')} "
        notOnlyDescriptionChanged = true
      end

      if self.city_changed? || self.street_changed? || self.zip_code_changed? || self.country_changed? || self.latitude_changed? || self.longitude_changed?
        text = text + "at a new location"
        notOnlyDescriptionChanged = true
      end

      if notOnlyDescriptionChanged
          
        self.attendees.each do |user|
          if self.user != user
            if self.title_changed?
              notification = Notification.new
              notification.activity = self
              notification.user = user
              notification.type_notifications = 5
              notification.attribute_5 = self.title_was
              notification.save()
            end

            if self.start_changed?
              notification = Notification.new
              notification.activity = self
              notification.user = user
              notification.type_notifications = 6
              notification.save()
            end

            if self.city_changed? || self.street_changed? || self.zip_code_changed? || self.country_changed? || self.latitude_changed? || self.longitude_changed?
              notification = Notification.new
              notification.activity = self
              notification.user = user
              notification.type_notifications = 7
              notification.save()
            end

            Thread.new do
              user.devices.each do |device|
                 device.update_attribute(:badge,device.badge.to_i + 1)
                 APNS.send_notification(device.token,{:alert => text,:badge => device.badge,:sound => 'default',:other => {info: {id: self.id, type: 'edit activity'}}})
              end
            end
          end
        end 
      end
    end
  end
  
  def send_deleted_notificaiton
    puts "send_deleted_notificaiton"

    arrayUserThread = []

    self.attendees.each do |user|
      arrayUserThread << user
    end

    arrayUserThread.each do |user|
      Thread.new do
        user.devices.each do |device| 
           device.update_attribute(:badge,device.badge.to_i + 1)
           APNS.send_notification(device.token,{:alert => "#{self.title} is cancelled",:badge => device.badge,:sound => 'default',:other => {info: {id: self.id, type: 'delete activity'}}})
        end
      end
    end
  end
  
  
  
  def set_end_date
    self.end_date = self.start + (self.length.hour * 60 * 60 + self.length.min * 60 + self.length.sec)
  end
end

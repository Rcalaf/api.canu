class Message < ActiveRecord::Base
  attr_accessible :activity_id, :text, :activity_id, :user_id
  
  belongs_to :activity
  belongs_to :user
  
  after_create :send_chat_message_notification
  
  private 
    
  def send_chat_message_notification
     notifications = []
     receivers = self.activity.attendees.to_a
     receivers.delete self.user
     receivers.each do |user|
       user.devices.each do |device| 
          device.update_attribute(:badge,device.badge.to_i + 1)
          notifications << APNS::Notification.new(device.token,{:alert => "#{self.user.user_name}@#{self.activity.title} Chat:\n#{self.text[0..(101-self.activity.title.size-self.user.user_name.size)]}...",:badge => device.badge,:sound => 'default',:other => {info: {id: self.activity.id, type: 'chat'}}})
       end
     end
     APNS.send_notifications(notifications) unless notifications.empty?
  end
  
  
end

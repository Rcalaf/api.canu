class Message < ActiveRecord::Base
  attr_accessible :activity_id, :text, :activity_id, :user_id
  
  belongs_to :activity
  belongs_to :user
  
  after_create :send_chat_message_notification
  
  private 
    
  def send_chat_message_notification
    
   receivers = self.activity.attendees.to_a
   receivers.delete self.user
   receivers.each do |user|

    name = ""

    if self.user.first_name.blank?
      name = self.user.user_name
    else
      name = self.user.first_name
    end

    notification = Notification.new
    notification.activity = self.activity
    notification.user = user
    notification.type_notifications = 8
    notification.attribute_8 = name
    notification.save()

    Thread.new do
       user.devices.each do |device| 
        device.update_attribute(:badge,device.badge.to_i + 1)
        APNS.send_notification(device.token,{:alert => "#{name}: #{self.text[0..(101 - name.size)]}",:badge => device.badge,:sound => 'default',:other => {info: {id: self.activity.id, type: 'chat'}}})
       end
     end
   end
  end
end

class ActivityNotification < ActiveRecord::Base
  attr_accessible :device_id, :errors_nb, :notification_type, :sent_at, :activity_id
  
  belongs_to :device
  belongs_to :activity
  
  
  scope :not_sent, where('sent_at IS NULL')
  scope :go, where('notification_type = ?', 'go')
end

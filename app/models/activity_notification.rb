class ActivityNotification < ActiveRecord::Base
  attr_accessible :device_id, :errors_nb, :notification_type, :sent_at, :activity_id
  
  belongs_to :device
  belongs_to :activity
end

class Notification < ActiveRecord::Base
  attr_accessible :activity_id, :attribute_3_4, :attribute_5, :attribute_8, :type_notifications, :user_id

  belongs_to :activity
  belongs_to :user

end

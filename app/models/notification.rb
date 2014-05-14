class Notification < ActiveRecord::Base
  attr_accessible :activity_id, :attribute_3_4, :attribute_5, :type, :user_id

  belongs_to :activity
  belongs_to :user
  
end

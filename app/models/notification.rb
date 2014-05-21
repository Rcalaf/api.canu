class Notification < ActiveRecord::Base
  attr_accessible :activity_id, :attribute_3_4, :attribute_5, :attribute_8, :type_notifications, :user_id

  belongs_to :activity
  belongs_to :user

  before_save :check_validation_notifications

  private

  def check_validation_notifications
    false
  end

end
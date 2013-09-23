class Device < ActiveRecord::Base
  attr_accessible :token, :user_id
  
  belongs_to :user
  has_many :activity_notifications, order: 'created_at', dependent: :destroy
  
  validates :token, :presence => true
  validates :token, :uniqueness => true
end

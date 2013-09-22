class Device < ActiveRecord::Base
  attr_accessible :token, :user_id
  
  belongs_to :user
  
  validates :token, :presence => true
  validates :token, :uniqueness => true
end

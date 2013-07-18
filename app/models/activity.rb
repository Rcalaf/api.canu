class Activity < ActiveRecord::Base
  attr_accessible :description, :length, :start, :title, :user_id
  
  belongs_to :user 
end

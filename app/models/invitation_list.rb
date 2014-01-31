class InvitationList < ActiveRecord::Base
	
  belongs_to :user
  belongs_to :activity
  
  has_and_belongs_to_many :attendees,
                          class_name: "User",
                          join_table: "invitation_lists_users", 
                          association_foreign_key: "user_id", 
                          foreign_key: "invitation_list"

end

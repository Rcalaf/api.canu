class InvitationList < ActiveRecord::Base

  attr_accessible :user

  belongs_to :user
  belongs_to :activity
  
  has_and_belongs_to_many :attendees_invitation,
                          class_name: "User",
                          join_table: "invitation_lists_users", 
                          association_foreign_key: "user_id", 
                          foreign_key: "invitation_list_id"

  has_and_belongs_to_many :attendees_invitation_ghostusers,
                          class_name: "Ghostuser",
                          join_table: "invitation_lists_ghostusers", 
                          association_foreign_key: "ghostuser_id", 
                          foreign_key: "invitation_list_id"

end

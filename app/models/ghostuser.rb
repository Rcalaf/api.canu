class Ghostuser < ActiveRecord::Base
  attr_accessible :isLinked, :phone_number

  validates :phone_number, :uniqueness => true

  has_many :invitation_lists

  has_and_belongs_to_many :schedule_invitation_ghostusers,
                          class_name: "InvitationList",
                          join_table: "invitation_lists_ghostusers", 
                          association_foreign_key: "invitation_list_id", 
                          foreign_key: "ghostuser_id"

end

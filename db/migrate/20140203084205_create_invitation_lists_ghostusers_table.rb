class CreateInvitationListsGhostusersTable < ActiveRecord::Migration
  def change
    create_table :invitation_lists_ghostusers, :id => false do |t|
      t.belongs_to :invitation_list
      t.belongs_to :ghostuser
    end
  end
end

class CreateInvitationListsUsersTable < ActiveRecord::Migration
  def change
    create_table :invitation_lists_users, :id => false do |t|
      t.belongs_to :invitation_list
      t.belongs_to :user
    end
  end
end

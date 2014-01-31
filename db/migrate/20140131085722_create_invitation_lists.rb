class CreateInvitationLists < ActiveRecord::Migration
  def change
    create_table :invitation_lists do |t|
      t.belongs_to :user
      t.belongs_to :activity

      t.timestamps
    end
    add_index :invitation_lists, :user_id
    add_index :invitation_lists, :activity_id
  end
end

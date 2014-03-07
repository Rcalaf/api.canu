class AddInvitationTokenToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :invitation_token, :string
  end
end

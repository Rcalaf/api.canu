class AddPhoneNumberAndPhoneVerifiedToUser < ActiveRecord::Migration
  def change
    add_column :users, :phone_number, :string
    add_column :users, :phone_verified, :boolean
  end
end

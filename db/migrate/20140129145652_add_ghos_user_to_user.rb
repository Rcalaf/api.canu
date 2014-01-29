class AddGhosUserToUser < ActiveRecord::Migration
  def change
  	change_table :users do |t|
      t.belongs_to :ghostuser
    end
  end
end

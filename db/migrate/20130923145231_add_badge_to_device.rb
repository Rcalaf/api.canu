class AddBadgeToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :badge, :integer
  end
end

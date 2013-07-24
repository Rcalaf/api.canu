class AddAttachmentImageToActivities < ActiveRecord::Migration
  def self.up
    change_table :activities do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :activities, :image
  end
end

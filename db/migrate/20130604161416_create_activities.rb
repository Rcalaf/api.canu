class CreateActivities < ActiveRecord::Migration
  def change
    create_table :activities do |t|
      t.string :title
      t.text :description
      t.datetime :start
      t.time :length
      t.integer :user_id
    end
  end
end

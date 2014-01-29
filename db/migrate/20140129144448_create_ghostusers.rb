class CreateGhostusers < ActiveRecord::Migration
  def change
    create_table :ghostusers do |t|
      t.string :phone_number
      t.boolean :isLinked

      t.timestamps
    end
  end
end

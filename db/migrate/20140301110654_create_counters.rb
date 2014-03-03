class CreateCounters < ActiveRecord::Migration
  def change
    create_table :counters do |t|
      t.integer :user_id
      t.datetime :available_for
      t.boolean :unlock, :default => false

      t.timestamps
    end
  end
end

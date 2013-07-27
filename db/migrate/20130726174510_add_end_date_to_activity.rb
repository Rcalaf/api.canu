class AddEndDateToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :end_date, :dateTime
  end
end

class Counter < ActiveRecord::Base
  attr_accessible :available_for, :unlock, :user_id

  belongs_to :ghostuser

end

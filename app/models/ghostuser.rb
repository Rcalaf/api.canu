class Ghostuser < ActiveRecord::Base
  attr_accessible :isLinked, :phone_number

  validates :phone_number, :uniqueness => true

end

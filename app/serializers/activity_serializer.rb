class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start, :length
  
  has_one :user
end

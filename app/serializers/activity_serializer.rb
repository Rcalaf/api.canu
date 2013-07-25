class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start,:length, :city, :street, :zip_code, :country, :latitude, :longitude, :image_url
  
  has_one :user
  
 
  
  has_many :attendees, embed: :ids
  
  def image_url
    object.image.url(:default, timestamp: false)
  end
  
  def location
    "{Street=#{object.street};City=#{object.city};ZIP=#{object.zip_code};Country=#{object.country};latitude=#{object.latitude};longitude=#{object.longitude}}"
  end
end

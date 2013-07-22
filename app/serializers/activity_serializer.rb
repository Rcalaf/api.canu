class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start,:length, :city, :street, :zip_code, :country, :latitude, :longitude
  
  has_one :user
  
  def location
    "{Street=#{object.street};City=#{object.city};ZIP=#{object.zip_code};Country=#{object.country};latitude=#{object.latitude};longitude=#{object.longitude}}"
  end
end

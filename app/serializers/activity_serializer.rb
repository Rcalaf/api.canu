class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start, :length, :end_date, :city, :street, :zip_code, :country, :latitude, :longitude, :image_url
  
  has_one :user
  has_many :attendees, embed: :ids
  
  def image_url
    object.image.url(:default, timestamp: false)
  end
  
  def attributes
    data = super
    data.delete :token
    data
  end
end

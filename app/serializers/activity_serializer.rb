class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :start, :length, :end_date, :city, :street, :zip_code, :country, :latitude, :longitude, :user
  
  #has_one :user
  has_many :attendees, embed: :ids
  
  def attributes
    data = super
    data.delete :token
    data
  end
  

  def user
    user = object.user
    {id:user.id,user_name: user.user_name, first_name: user.user_name,email: user.email,active: user.active, phone_number: user.phone_number, phone_verified: user.phone_verified ,profile_pic: user.profile_image.url(:default, timestamp: false) }
  end

end

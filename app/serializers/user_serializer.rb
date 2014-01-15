class UserSerializer < ActiveModel::Serializer
  attributes :id, :token, :first_name, :last_name, :email, :active, :profile_pic, :user_name, :phone_number, :phone_verified#, :schedule
  
  def profile_pic
    object.profile_image.url(:default, timestamp: false)
  end
  
  #def token
  # object.api_keys.first.access_token if object.api_keys.first     
  #end
end

class UserSerializer < ActiveModel::Serializer
  attributes :id, :token, :first_name, :last_name, :email, :active, :profile_pic, :user_name
  
  def profile_pic
    object.profile_image.url(:default, timestamp: false)
  end
end

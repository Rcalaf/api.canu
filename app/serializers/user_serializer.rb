class UserSerializer < ActiveModel::Serializer
  attributes :id, :token, :first_name, :last_name, :email, :active, :profile_pic, :user_name
  
  def profile_pic
    "this would be the pic url"
  end
end

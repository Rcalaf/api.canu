class UserSerializer < ActiveModel::Serializer
  attributes :id, :token, :first_name, :last_name, :email, :active, :profile_pic
  
  def profile_pic
    "this would be the pic url"
  end
end

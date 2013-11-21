class MessageSerializer < ActiveModel::Serializer
  attributes :id, :text, :created_at, :user
  
 # has_one :user
   
   def user
    user = object.user
    {id:user.id,user_name: user.user_name,profile_pic: user.profile_image.url(:default, timestamp: false) }
   end
   
end

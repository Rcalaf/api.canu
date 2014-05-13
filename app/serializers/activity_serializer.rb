class ActivitySerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :attendee_ids, :start, :length, :end_date, :city, :street, :zip_code, :country, :latitude, :longitude, :private_location, :user, :invitation_token, :place_name
  
  #has_one :user
  # has_many :attendees, embed: :ids



  def attributes
    activity = object
    attendees = []
    activity.attendees.each do |attendee| 
        if attendee.phone_verified
          attendees << attendee.id
        end
    end
    activity.attendee_ids = attendees
  end
  
  def attributes

    data = super
    data.delete :token
    data
  end
  

  def user
    user = object.user
    
    if user.nil?
      {id:"Unknown",
       user_name: "Unknown", 
       first_name: "Unknown",
       email: "Unknown",
       active: "Unknown", 
       phone_number: "Unknown", 
       phone_verified: "Unknown",
       profile_pic: "Unknown" }
      
    else

      first_name = ""

      if !user.first_name.nil?
        first_name = user.first_name
      end

      {id:user.id,user_name: user.user_name, first_name: user.first_name,email: user.email,active: user.active, phone_number: user.phone_number, phone_verified: user.phone_verified ,profile_pic: user.profile_image.url(:default, timestamp: false) }
    end
  end

end

class UsersController < ApplicationController
   before_filter :restrict_access, :except => [:create,:mail_verification,:sms_verification,:sms_verification_v2_failed]
  
  def index
    render json: User.all
  end
  
  def activities
    if params[:type] == "profile"
      user = User.find(params[:user_id])
      render json: user.schedule.active(Time.zone.now)
    elsif params[:type] == "tribes"
      user = User.find(params[:user_id])
      allActivities = Array.new
      user.schedule_invitation.each do |invitationList|
        act = Activity.find_by_id(invitationList.activity_id)
        if act
          if act.end_date > Time.zone.now
            allActivities << act
          end
        end
      end
      user.activities.each do |act|
        if act.user_id == user.id && act.end_date > Time.zone.now && act.private_location
          allActivities << act
        end
      end
      if user.ghostuser
        user.ghostuser.schedule_invitation_ghostusers.each do |invitationListGhost|
          act = Activity.find_by_id(invitationListGhost.activity_id)
          if act
            if act.end_date > Time.zone.now
              allActivities << act
            end
          end
        end
      end
      allActivitiesSorted = allActivities.sort { |a,b| a.start <=> b.start }
      render json: allActivitiesSorted
    end
  end
  
  def mail_verification
    parsed_token = params[:token].split('#')
    user = User.find(parsed_token[1])
    if user && user.mail_verification_token == parsed_token[0]
        user.update_attribute(:active, true)
        redirect_to 'http://www.canu.se/email-confirmed'
     end
  end
  
  def sms_verification
    text,info = params[:text].split('.')

    if info
      
      token, id = info.strip.split('#')
      user = User.find_by_id(id)
      
      if user && token.rstrip == Digest::SHA1.hexdigest(user.id.to_s + 'canuGettogether' + user.email)

        if user.phone_number != "+"+params[:msisdn]

          # Disable phone_verified to users when theys have this phone number
          usersWithSamePhoneNumbers = User.where('phone_number = ?',"+"+params[:msisdn])
          usersWithSamePhoneNumbers.each do |userWithSamePhoneNumber|
            userWithSamePhoneNumber.update_attributes(phone_number: nil,phone_verified: false)
          end

          user.update_attributes(phone_number:"+"+params[:msisdn],phone_verified: true)

          ghostuser = Ghostuser.find_by_phone_number("+"+params[:msisdn])

          if ghostuser
            user.ghostuser = ghostuser
            user.save
            ghostuser.update_attributes(isLinked: true)
          end

        end

      end

    end

    render json: params
  end

  def sms_verification_v2
      
    user = User.find_by_id(params[:user_id])
    if user
      # Disable phone_verified to users when theys have this phone number
      usersWithSamePhoneNumbers = User.where('phone_number = ?',params[:phone_number])
      usersWithSamePhoneNumbers.each do |userWithSamePhoneNumber|
        userWithSamePhoneNumber.update_attributes(phone_number: nil,phone_verified: false)
      end
      
      user.update_attributes(phone_number:params[:phone_number],phone_verified: true)

      ghostuser = Ghostuser.find_by_phone_number(params[:phone_number])

      if ghostuser
        user.ghostuser = ghostuser
        user.save
        ghostuser.update_attributes(isLinked: true)
      end

      render json: user, status: 200

    else
      render json: params, status: 400
    end
    
  end

  def sms_verification_v2_failed

    Mailer.sms_failed().deliver
    puts params
    puts "Phone number:"
    puts params[:msisdn]
    if params[:msisdn][0,1] == 1
      puts "US Phone number"
    else
      puts "Not US Phone number"
    end
    puts "Status:"
    puts params[:status]
    if params[:status] == "delivered"
      puts "It's delivered"
    else
      puts "It's not delivered"
    end
    puts "Error code:"
    # puts params[:err-code]

    render json: "",status: 200

  end

  def phonebook

    allUsers = Array.new

    usersWithPhoneNumber = User.where('phone_verified = ?',true)

    params[:phone_numbers].each do |phone_number|

      user = usersWithPhoneNumber.find_by_phone_number(phone_number)

      if user
        allUsers << user
      end

    end

    render json: allUsers

  end
  
  def create

    last_name = ""

    if params[:first_name]
      last_name = params[:first_name].split(' ').last
    end
    user = {email: params[:email],first_name: params[:first_name],last_name:last_name, proxy_password: params[:proxy_password], user_name: params[:user_name], profile_image: params[:profile_image]}
    user = User.create(user)

    if user.valid?
      if !user.email.nil?
        Mailer.welcome(user).deliver
      end
      render json: user, status: 200
    else
      render json: user.errors, status: 400
      puts user
    end
  end

  def update
    user = User.find(params[:id])
    if user.update_attributes(params[:user])
      render json: user, status: 200
    else 
      render json: user.errors, status: 400
    end
  end
  
  def update_profile_pic
    user = User.find(params[:user_id])
    if user.update_attribute(:profile_image,params[:profile_image])
      render json: user
    else
      render json: user.errors, status: 400
    end
  end
  
  def set_device_token
    user = User.find(params[:user_id]) 
    # if this device token is saved for another one user / Delete this token
    allSameDevices = Device.where('token = ?',params[:device_token])
    allSameDevices.each do |sameDevice|
      if sameDevice.user_id != user.id
        sameDevice.destroy()
      end
    end

    device = Device.create(token: params[:device_token], user_id: user.id)
    #if user.devices << Device.create(:token => params[:device_token])
    if device.valid?
       render json: {user: user, device: device}
    else
       render json: {user: user, device_errors: device.errors}, status: 200
    end
  end
  
  def destroy
    render json: User.destroy(params[:id])
  end
  
end

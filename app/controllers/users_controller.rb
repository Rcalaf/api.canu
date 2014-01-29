class UsersController < ApplicationController
   before_filter :restrict_access, :except => [:create,:mail_verification,:sms_verification]
  
  def index
    render json: User.all
  end
  
  def activities
    user = User.find(params[:user_id])
    render json: user.schedule.active(Time.zone.now)
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
    token, id = info.strip.split('#')
    user = User.find_by_id(id)
    #Mailer.sms({token:token, user_id:id, text:text, user:user}).deliver
    if user && token.rstrip == Digest::SHA1.hexdigest(user.id.to_s + 'canuGettogether' + user.email)

      # Disable phone_verified to users when theys have this phone number
      usersWithSamePhoneNumbers = User.where('phone_number = ?',"+"+params[:msisdn])
      usersWithSamePhoneNumbers.each do |userWithSamePhoneNumber|
        userWithSamePhoneNumber.update_attributes(phone_number: nil,phone_verified: false)
      end

      user.update_attributes(phone_number:"+"+params[:msisdn],phone_verified: true)

      ghostuser = Ghostuser.find_by_phone_number(params[:phone_number])

      if ghostuser
        user.ghostuser = ghostuser
        user.save
        ghostuser.update_attributes(isLinked: true)
      end
      
    end
    render json: params
  end

  def sms_verification_dev
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

    end
    render json: params
  end
  
  def create
    user = {email: params[:email],first_name: params[:first_name],last_name:params[:first_name].split(' ').last, proxy_password: params[:proxy_password], user_name: params[:user_name], profile_image: params[:profile_image]}
    user = User.create(user)
    if user.valid?
      Mailer.welcome(user).deliver
      render json: user, status: 201
    else
      render json: user.errors, status: 400
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

class UsersController < ApplicationController
   before_filter :restrict_access, :except => [:create,:mail_verification,:sms_verification,:sms_verification_v2_failed,:send_sms_reset_password,:reset_password]
  
   serialization_scope nil

  def index
    render json: User.all
  end
  
  def activities
    if params[:type] == "public"
      user = User.find(params[:user_id])
      if (params[:latitude] && params[:longitude])
        render json: Activity.active(Time.zone.now).in_range(params[:latitude].to_f,params[:longitude].to_f).privacy_location(false), scope: user
      else
        render json: Activity.active(Time.zone.now).privacy_location(false), scope: user
      end

    elsif params[:type] == "profile"
      user = User.find(params[:user_id])
      render json: user.schedule.active(Time.zone.now), scope: user
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
      render json: allActivitiesSorted, scope: user
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

      if user.phone_number != params[:phone_number]
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
        render json: user, status: 200
      end

    else
      render json: params, status: 400
    end
    
  end

  def sms_verification_v2_failed

    render json: "",status: 200

  end

  def send_sms

    require 'net/http' 
    require 'uri'

    phoneNumber = params[:phone_number]

    url = ""

    phoneNumber = phoneNumber.gsub(/\s+/, "")
    phoneNumber = phoneNumber.gsub(/-+/, "")
    
    # Use short code
    if params[:country_code] == "+1"

      if params[:country_name] == "Canada"
        
        text = "Your code : " + params[:code]
        url = "https://rest.nexmo.com/sms/json?api_key=a86782bd&api_secret=68a115a0&from=12069396333&to=" + phoneNumber + "&text=" + text
        
      else
        url = "https://rest.nexmo.com/sc/us/2fa/json?api_key=a86782bd&api_secret=68a115a0&to=" + phoneNumber + "&pin=" + params[:code]
      end

    else

      if params[:country_code] == "+44"
        phoneNumber = "00" + phoneNumber
      end

      text = "Your code : " + params[:code]

      url = "https://rest.nexmo.com/sms/json?api_key=a86782bd&api_secret=68a115a0&from=CANU&to=" + phoneNumber + "&text=" + text

    end

    uri = URI.parse(URI.encode(url))

    http = Net::HTTP.new(uri.host, uri.port) 
    request = Net::HTTP::Get.new(uri.path) 
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
    request = Net::HTTP::Get.new( uri.to_s )

    response = http.request(request)

  end

  def send_sms_reset_password

    usersWithPhoneNumber = User.where('phone_verified = ?',true)
    user = usersWithPhoneNumber.find_by_phone_number("+" + params[:phone_number])

    if user

      # Dev mode
      if params[:key] == "9384nc934875"
        render json: user, status: 200
      else

        require 'net/http' 
        require 'uri'


        phoneNumber = params[:phone_number]

        url = ""

        phoneNumber = phoneNumber.gsub(/\s+/, "")
        phoneNumber = phoneNumber.gsub(/-+/, "")
        
        # Use short code
        if params[:country_code] == "+1"

          if params[:country_name] == "Canada"
            
            text = "Your code : " + params[:code]
            url = "https://rest.nexmo.com/sms/json?api_key=a86782bd&api_secret=68a115a0&from=12069396333&to=" + phoneNumber + "&text=" + text
            
          else
            url = "https://rest.nexmo.com/sc/us/2fa/json?api_key=a86782bd&api_secret=68a115a0&to=" + phoneNumber + "&pin=" + params[:code]
          end

        else

          if params[:country_code] == "+44"
            phoneNumber = "00" + phoneNumber
          end

          text = "Your code : " + params[:code]

          url = "https://rest.nexmo.com/sms/json?api_key=a86782bd&api_secret=68a115a0&from=CANU&to=" + phoneNumber + "&text=" + text

        end

        uri = URI.parse(URI.encode(url))

        http = Net::HTTP.new(uri.host, uri.port) 
        request = Net::HTTP::Get.new(uri.path) 
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE # read into this
        request = Net::HTTP::Get.new( uri.to_s )

        response = http.request(request)

        render json: user, status: 200

      end

    else
      render json: user.errors, status: 400
    end
    
  end

  def phonebookandtribe

    tribes = []

    relationsTribe = Tribe.where('user_id = ?',params[:user_id])

    relationsTribe.each do |relation|
      user = User.find_by_id(relation.friend_id)
      tribes << {id: user.id, first_name: user.first_name, last_name:user.last_name, 
                  email:user.email, active:user.active, profile_pic: user.profile_image.url(:default, timestamp: false),
                  user_name: user.user_name, phone_number: user.phone_number, 
                  phone_verified:user.phone_verified }
    end

    allUsers = Array.new

    usersWithPhoneNumber = User.where('phone_verified = ?',true)

    params[:phone_numbers].each do |phone_number|

      user = usersWithPhoneNumber.find_by_phone_number(phone_number)

      if user
        allUsers << {id: user.id, first_name: user.first_name, last_name:user.last_name, 
                    email:user.email, active:user.active, profile_pic: user.profile_image.url(:default, timestamp: false),
                    user_name: user.user_name, phone_number: user.phone_number, 
                    phone_verified:user.phone_verified }
      end

    end

    render json: {users:allUsers,tribe:tribes}

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

  def reset_password

    if params[:key] == "9348yr20qo98r4"

      puts params[:user_id]

      user = User.find(params[:user_id])
      if user.update_attributes(params[:user])
        render json: user, status: 200
      else 
        render json: user.errors, status: 400
      end
    else
      puts "rien"
      render json: "", status: 400
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
    # delete previous token
    user.devices.each do |device| 
      device.destroy()
    end

    countNotifs = 0

    allNotifsUser = Notification.where('user_id = ?', user.id).where(:read =>  false)

    allNotifsUser.each do |notif|
      if notif.activity.end_date > Time.zone.now
        countNotifs = countNotifs + 1
      end
    end

    device = Device.create(token: params[:device_token], user_id: user.id,  badge: countNotifs)
    #if user.devices << Device.create(:token => params[:device_token])
    if device.valid?
       render json: {user: user, device: device, number_notifications: countNotifs}
    else
      previousDevice = Device.find_by_token(params[:device_token])
      previousDevice.update_attribute(:badge,countNotifs)
      render json: {user: user, device_errors: device.errors, number_notifications: countNotifs}, status: 200
    end
  end

  def search_users
    
    users = User.search params[:search]
    render json: users, status: 200

  end
  
  def destroy
    render json: User.destroy(params[:id])
  end
  
end

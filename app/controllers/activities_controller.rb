class ActivitiesController < ApplicationController
  before_filter :restrict_access, :except => [:index, :show, :attendees]
 
  
  def index
    if (params[:latitude] && params[:longitude])
      render json: Activity.active(Time.zone.now).in_range(params[:latitude].to_f,params[:longitude].to_f).privacy_location(false)
    else
      render json: Activity.active(Time.zone.now).private_location(false)
    end
  end
  
  def create
    activity = {description: params[:description],title: params[:title].rstrip,
                length: params[:length] , start: Time.parse(params[:start]).utc.to_s, #end_date:  params[:end], 
                user_id: params[:user_id], city: params[:city],
                street: params[:street], zip_code: params[:zip],
                country: params[:country], latitude: params[:latitude],
                longitude: params[:longitude], private_location: params[:private_location]}
    activity = Activity.create(activity)
    if activity.valid?
      if activity.user.schedule << activity

        if params[:guests].count != 0
          invitationList = InvitationList.new

          invitationList.user = activity.user
          invitationList.activity = activity

          params[:guests].each do |phone_number|

            user = User.find_by_phone_number(phone_number)

            if user
              invitationList.attendees_invitation << user
            else
              ghostuser = Ghostuser.find_by_phone_number(phone_number)
              if !ghostuser
                ghostuser = Ghostuser.create(isLinked: false, phone_number: phone_number)
              end
              invitationList.attendees_invitation_ghostusers << ghostuser
            end

          end

          invitationList.save

        end

      end
      Activity.send_created_notification(activity)
      render json: activity, status: 201
    else
      render json: activity.errors, status: 400
    end
  end
  
  def update
    activity_params = {description: params[:description],title: params[:title].rstrip,
                length: params[:length] , start: Time.parse(params[:start]).utc.to_s, #end_date:  params[:end], 
                user_id: params[:user_id], city: params[:city],
                street: params[:street], zip_code: params[:zip],
                country: params[:country], latitude: params[:latitude],
                longitude: params[:longitude]}
    activity = Activity.find(params[:activity_id])            
    if activity.update_attributes(activity_params)
      render json: activity
    else
      render json: activity.errors
    end
  end
  
  def add_to_schedule
    puts "add_to_schedule_test1"
    activity = Activity.find(params[:activity_id])
    user = User.find(params[:user_id])
    if user.schedule << activity
      #user.devices.each {|device| device.activity_notifications.create(activity_id: activity.id,notification_type: 'go') }
    end
    if (params[:latitude] && params[:longitude])
      render json: Activity.active(Time.zone.now).in_range(params[:latitude].to_f,params[:longitude].to_f)
    else
      render json: Activity.active(Time.zone.now)
    end
  end

  def remove_from_schedule
    puts "remove_to_schedule_test1"
    activity = Activity.find(params[:activity_id])
    user = User.find(params[:user_id])
    if user.schedule.delete activity
      #user.devices.each {|device| device.activity_notifications.find_by_activity_id(activity.id).delete if device.activity_notifications.find_by_activity_id(activity.id)}
    end
    if (params[:latitude] && params[:longitude])
      render json: Activity.active(Time.zone.now).in_range(params[:latitude].to_f,params[:longitude].to_f)
    else
      render json: Activity.active(Time.zone.now)
    end
  end
  
  def show
    activity = Activity.find(params[:id])
    render json: activity
  end
  
  def attendees
    user = User.find_by_id(params[:user_id])
    if user
      activity = Activity.find(params[:activity_id])
      invitationList = InvitationList.where('activity_id = ? AND user_id = ?',params[:activity_id],user.id).first
      if invitationList

        #If user already on Attendees, disappear this one to the invitation list

        arrayUserInvited = Array.new()

        invitationList.attendees_invitation.each do |userInvited|
          userIsAttendees = false
          activity.attendees.each do |userAttendee|
            if userAttendee.id == userInvited.id
              userIsAttendees = true
            end
          end

          if !userIsAttendees
            arrayUserInvited << userInvited
          end
        end

        render json: {
          attendees: activity.attendees, 
          invitation:{
            users: arrayUserInvited,
            ghostuser: invitationList.attendees_invitation_ghostusers
          }
        }
      else
        render json: {
          attendees: activity.attendees
        }
      end
    else
      activity = Activity.find(params[:activity_id])
      render json: activity.attendees
    end
    
  end
  
  def destroy
    render json: Activity.destroy(params[:activity_id])
  end
  

end

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
        #activity.user.devices.each {|device| device.activity_notifications.create(activity_id: activity.id,notification_type: 'go') }

        if params[:guests].count != 0
          invitationList = InvitationList.new

          invitationList.user = activity.user
          invitationList.activity = activity

          params[:guests].each do |phone_number|

            user = User.find_by_phone_number(phone_number)

            if user
              invitationList.attendees_invitation << user
              puts "Add User"
            end

          end

          invitationList.save

        end

        puts "Test 3"

      end
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
    activity = Activity.find(params[:activity_id])
    render json: activity.attendees
  end
  
  def destroy
    render json: Activity.destroy(params[:activity_id])
  end
  

end

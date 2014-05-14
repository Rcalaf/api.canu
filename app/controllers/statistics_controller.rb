class StatisticsController < ApplicationController
  def index
    user = {
    	total: User.all.size, 
    	ghost: Ghostuser.where(isLinked: false).size, 
    	total_phone_verified: User.where(phone_verified: true).size, 
    	total_email_verified: User.where(active: true).size, 
    	not_verified: User.where('(active = false || active is null) && (phone_verified = false || phone_verified is null) ').size 
    }
    activity = {
    	total: Activity.all.size, 
    	total_active: Activity.where(' user_id != 1 || user_id != 7 || user_id != 1 || user_id != 8 || user_id != 14 || user_id != 19 || user_id != 26 || user_id != 27 || user_id != 228 || user_id != 227 || user_id != 1002').active(Time.zone.now).size,
    	total_active_local: Activity.where(' user_id != 1 ||  user_id != 7 || user_id != 1 || user_id != 8 || user_id != 14 || user_id != 19 || user_id != 26 || user_id != 27 || user_id != 228 || user_id != 227 || user_id != 1002').active(Time.zone.now).privacy_location(false).size,
    	total_active_tribe: Activity.where(' user_id != 1 ||  user_id != 7 || user_id != 1 || user_id != 8 || user_id != 14 || user_id != 19 || user_id != 26 || user_id != 27 || user_id != 228 || user_id != 227 || user_id != 1002').active(Time.zone.now).privacy_location(true).size, 
    	active_activities_locations: Activity.where(' user_id != 1 ||  user_id != 7 || user_id != 1 || user_id != 8 || user_id != 14 || user_id != 19 || user_id != 26 || user_id != 27 || user_id != 228 || user_id != 227 || user_id != 1002').select('latitude,longitude').active(Time.zone.now).privacy_location(true), 
    	active_activities_locations_local: Activity.where(' user_id != 1 ||  user_id != 7 || user_id != 1 || user_id != 8 || user_id != 14 || user_id != 19 || user_id != 26 || user_id != 27 || user_id != 228 || user_id != 227 || user_id != 1002').select('latitude,longitude').active(Time.zone.now).privacy_location(false)
    }
    render json: {
    	user: user, 
    	activity: activity
    	}, status: 200
  end
  
end


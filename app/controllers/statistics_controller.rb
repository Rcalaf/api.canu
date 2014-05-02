class StatisticsController < ApplicationController
  def index
    user = {total: User.all.size, ghost: Ghostuser.where(isLinked: false).size, total_phone_verified: User.where(phone_verified: true).size, total_email_verified: User.where(active: true).size, not_verified: User.where('(active = false || active is null) && (phone_verified = false || phone_verified is null) ').size }
    activity = {total: Activity.all.size, total_active: Activity.active(Time.zone.now).size,total_active_local: Activity.active(Time.zone.now).privacy_location(false).size,total_active_tribe: Activity.active(Time.zone.now).privacy_location(true).size, active_activities_locations: Activity.select('latitude,longitude').active(Time.zone.now).privacy_location(true), active_activities_locations_local: Activity.select('latitude,longitude').active(Time.zone.now).privacy_location(false)}
    render json: {user: user, activity: activity}, status: 200
  end
end


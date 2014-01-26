class StatisticsController < ApplicationController
  def index
    user = {total: User.all.size, total_phone_verified: User.where(phone_verified: true).size, total_email_verified: User.where(active: true).size}
    activity = {total: Activity.all.size, total_active: Activity.active(Time.zone.now).size, active_activities_locations: Activity.select('latitude,longitude').active(Time.zone.now)}
    render json: {user: user, activity: activity}, status: 200
  end
end

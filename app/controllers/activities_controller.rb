class ActivitiesController < ApplicationController
  
  def index
    render json: Activity.active
  end
  
  def create
    activity = {description: params[:description],title: params[:title],
                length: params[:length] , start: params[:start], #end_date:  params[:end], 
                user_id: params[:user_id], city: params[:city],
                street: params[:street], zip_code: params[:zip],
                country: params[:country], latitude: params[:latitude],
                longitude: params[:longitude], image: params[:image]}
    activity = Activity.create(activity)
    if activity.valid?
      activity.user.schedule << activity
      render json: activity, status: 201
    else
      render json: activity.errors, status: 400
    end
  end
  
  def update
    activity_params = {description: params[:description],title: params[:title],
                length: params[:length] , start: params[:start], #end_date:  params[:end], 
                user_id: params[:user_id], city: params[:city],
                street: params[:street], zip_code: params[:zip],
                country: params[:country], latitude: params[:latitude],
                longitude: params[:longitude], image: params[:image]}
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
    user.schedule << activity
    render json: Activity.active
    # {}
  end

  def remove_from_schedule
    activity = Activity.find(params[:activity_id])
    user = User.find(params[:user_id])
    user.schedule.delete activity
    render json: Activity.active
  end
  
  def show
    activity = Activity.find(params[:id])
    render json: activity
  end
  
  def destroy
    render json: Activity.destroy(params[:id])
  end
  
end

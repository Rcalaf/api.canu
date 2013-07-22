class ActivitiesController < ApplicationController
  
  def index
    render json: Activity.all
  end
  
  def create
    activity = {description: params[:description],title: params[:title],
                length: params[:length] , start: params[:start], 
                user_id: params[:user_id], city: params[:city],
                street: params[:street], zip_code: params[:zip],
                country: params[:country], latitude: params[:latitude],
                longitude: params[:longitude]}
    activity = Activity.create(activity)
    if activity.valid?
      render json: activity, status: 201
    else
      render json: activity.errors, status: 400
    end
  end
  
  def show
    activity = Activity.find(params[:id])
    render json: activity
  end
  
  def destroy
    render json: Activity.destroy(params[:id])
  end
  
end

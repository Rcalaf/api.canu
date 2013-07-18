class ActivitiesController < ApplicationController
  
  def index
    render json: Activity.all
  end
  
  def create
    activity = {description: params[:description],title: params[:title],length: params[:length] , start: params[:start], user_id: params[:user_id]}
    activity = Activity.create(activity)
    if activity.valid?
      render json: activity, status: 201
    else
      render json: activity.errors, status: 400
    end
  end
  
  def destroy
    render json: Activity.destroy(params[:id])
  end
  
end

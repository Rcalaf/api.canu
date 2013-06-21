class ActivitiesController < ApplicationController
  
  def index
    render json: Activity.all
  end
  
  def create
    activity = {description: params[:description],title: params[:title],length: params[:length] , start: params[:start], user_id: params[:user_id]}
    render json: Activity.create(activity)
  end
  
  def destroy
    render json: Activity.destroy(params[:id])
  end
  
end

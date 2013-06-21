class UsersController < ApplicationController
   before_filter :restrict_access
  
  def index
    render json: User.all
  end
  
  def create
    render json: User.create(params[:user])
  end
  
  def destroy
    render json: User.destroy(params[:id])
  end
  
end

class UsersController < ApplicationController
   before_filter :restrict_access, :except => [:create]
  
  def index
    render json: User.all
  end
  
  def activities
    user = User.find(params[:user_id])
    render json: user.schedule.active(Time.zone.now)
  end
  
  #def mail_verification
  #  user = User.find_by_email(params[:email])
  #  if user
  #      user.update_attribute(:active, true)
  #   end
  #end
  
  def create
    user = {email: params[:email],first_name: params[:first_name],last_name:params[:first_name].split(' ').last, proxy_password: params[:proxy_password], user_name: params[:user_name], profile_image: params[:profile_image]}
    user = User.create(user)
    if user.valid?
     # Mailer.welcome(user).deliver
      render json: user, status: 201
    else
      render json: user.errors, status: 400
    end
  end

  def update
    user = User.find(params[:id])
    if user.update_attributes(params[:user])
      render json: user, status: 200
    else 
      render json: user.errors, status: 400
    end
  end
  
  def update_profile_pic
    user = User.find(params[:user_id])
    if user.update_attribute(:profile_image,params[:profile_image])
      render json: user
    else
      render json: user.errors, status: 400
    end
  end
  
  def set_device_token
    user = User.find(params[:user_id]) 
    if user.devices << Device.create(:token => params[:device_token])
       render json: user
    else
       render json: user.errors, status: 400
    end
  end
  
  def destroy
    render json: User.destroy(params[:id])
  end
  
end

class SessionController < ApplicationController

   
  def user
    user = User.find_by_token(params[:token])
    #api_key = ApiKey.find_by_access_token(params[:token])
    #user = api_key.nil? ? nil : api_key.user
    #puts user
    if user
      render json: user, status:200
    else
      render json: {}, status:400
    end
  end
  
  def check_user_name
    if User.find_by_user_name(params[:user_name])
      render json: {}, status: 400
    else
      render json: {}, status: 200
    end
  end
  
  def login
   if request.post?
      user = User.authenticate(params[:email],params[:password])
      if user.errors.empty?
        render json: user
      else
        render json: user.errors, status: 404
      end
    end
  end
  
  def logout
    if request.post?
      user = User.find_by_token(params[:token])
      #api_key = ApiKey.find_by_access_token(params[:token])
      #user = api_key.nil? ? nil : api_key.user
      if user
        render json: user.update_attribute(:token,nil)
      #  render json: user, status: 200 
      else
        render json: nil, status: 200 
      end
    end
  end
  
  
end

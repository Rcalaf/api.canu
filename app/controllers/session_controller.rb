class SessionController < ApplicationController

   
  def user
    user = User.find_by_token(params[:token])
    #api_key = ApiKey.find_by_access_token(params[:token])
    #user = api_key.nil? ? nil : api_key.user
    #puts user
    render json: user
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

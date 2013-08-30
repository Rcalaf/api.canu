class SessionController < ApplicationController
  
  def user
    user = User.find_by_token(params[:token])
    puts user
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
      if user
        render json: user.update_attribute(:token,nil)
      else
        render json: nil, status: 404  
      end
    end
  end
  
  
end

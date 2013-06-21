class SessionController < ApplicationController
  
  def login
   if request.post?
      user = User.authenticate(params[:email],params[:password])
      if user.class == User
        render json: user
      else
        render json: user, status: 404
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

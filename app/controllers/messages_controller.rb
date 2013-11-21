class MessagesController < ApplicationController
  
  def messages
    @activity = Activity.find(params[:activity_id])
    @messages = @activity.messages
    render json: @messages
  end
  
  def create
    message = Message.create(params[:message])
    if message.valid?
      render json: message, status: 201
    else
      render json: message.errors, status: 400
    end
  end
  
end

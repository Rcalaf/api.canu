class DevicesController < ApplicationController
  before_filter :restrict_access
  
  def badge
    device = Device.find_by_token(params[:device_token])
    render json: device.badge, status: 201
  end
  
  def edit_badge
    device = Device.find_by_token(params[:device_token])
    if device.update_attribute(:device_token, params[:badge_value])
      render json: true, status: 201
    else
      render json: false, status: 400
    end
  end
  
end

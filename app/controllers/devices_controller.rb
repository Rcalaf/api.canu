class DevicesController < ApplicationController
  before_filter :restrict_access
  
  def badge
    device = Device.find_by_token(params[:device_token])
    render json: device.badge, status: 201
  end
  
  def edit_badge
    device = Device.find_by_token(params[:device_token])
    if device.update_attribute(:badge, params[:badge])
      render json: device, status: 201
    else
      render json: params, status: 400
    end
  end
  
end

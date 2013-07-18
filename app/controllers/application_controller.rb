class ApplicationController < ActionController::API
  
  private
  
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
        User.exists?(token: token)
#        ApiKey.exists?(access_token: token )
    end
  end
end

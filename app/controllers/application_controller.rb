class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  def default_serializer_options
    {root: false}
  end
  
  private
  
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
        User.exists?(token: token)
#        ApiKey.exists?(access_token: token )
    end
  end
end

class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  
  def default_serializer_options
    {root: false}
  end
  
  private
  
  def restrict_access
    authenticate_or_request_with_http_token do |token, options|
        User.exists?(token: token)
#         ApiKey.exists?(access_token: token )
    end
  end
  
  protected

  def authenticate
    authenticate_or_request_with_http_basic("Please insert credentials") do |username,password|
      username == "Canu" && password == "itshalfpast8!"
    end
  end
end

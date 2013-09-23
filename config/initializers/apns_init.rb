#if Rails.env.production?
#  APNS.pem  = "#{Rails.root}/config/certs/apns-prod.pem"
#else
  APNS.pem  = "#{Rails.root}/config/certs/apns-dev.pem"
#end

if Rails.env.production?
  APNS.host = 'gateway.push.apple.com'
  APNS.pem  = "#{Rails.root}/config/certs/apns-prod.pem"
else
  APNS.pem  = "#{Rails.root}/config/certs/apns-dev.pem"
end

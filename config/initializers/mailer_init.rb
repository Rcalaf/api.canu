ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => 'smtp.canu.se',
  :port => 25,
  :domain => 'www.canu.se',
  :authentication => :login,
  :user_name => 'gettogether@canu.se',
  :password => 'Itshalfpast8',
  :enable_starttls_auto => true,
  :openssl_verify_mode => 'none'
}

ActionMailer::Base.default_url_options[:host] = "canu.se"

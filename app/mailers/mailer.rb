# encoding: UTF-8
class Mailer < ActionMailer::Base
  default from: 'CANU <gettogether@canu.se>'
  
  def welcome(user)
    @user = user
    mail(:to => user.email, :subject => 'Welcome to CANU')
  end
  
  def sms(values)
     @values = values
     mail(:to => 'roger@canu.se',:cc => ['didrik@canu.se','vitali@canu.se'], :subject => 'CANU SMS callback')
  end
  
  def email_confirmation(user)
    @user = user
    mail(:to => user.email, :subject => 'CANU: user confirmation')
  end
 
end

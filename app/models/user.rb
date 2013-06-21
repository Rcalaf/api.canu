class User < ActiveRecord::Base
  attr_accessible :active, :email, :first_name, :last_name, :proxy_password, :password, :salt, :token, :user_name
  
  before_validation :downcase_email
  
  def proxy_password
    @proxy_password
  end
  
  def proxy_password=(pwd)
    @proxy_password = pwd
    return if pwd.blank?
    create_new_salt
    self.password = User.encrypted_password(self.proxy_password, self.salt)
  end
  
  def self.authenticate(email,password)
    user = User.find_by_email(email.downcase)
    if user
      expected_password = encrypted_password(password,user.salt)
      if user.password != expected_password
        user = {error: 'password'}
      else
        user.update_attribute(:token, User.generate_access_token)
        #ApiKey.create(user_id: user)
      end
    else
       user = {error: 'email'}
    end
    user
  end
  

  
  private  
  
    def self.generate_access_token
      begin 
        token = SecureRandom.hex
      end while self.exists?(token: token)
      return token
    end
   
   def downcase_email
     self.email = self.email.downcase
   end

   def self.encrypted_password(proxy_password,salt)
     string_to_hash = proxy_password + "gettogether" + salt
     Digest::SHA1.hexdigest(string_to_hash)
   end

   def create_new_salt
     self.salt = self.object_id.to_s + rand.to_s
   end

end

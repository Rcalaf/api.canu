# encoding: UTF-8
class User < ActiveRecord::Base
  attr_accessible :active, :email, :first_name, :last_name, :proxy_password, :password, :salt, :token, :user_name, :profile_image
  
  #before_validation :downcase_email
  before_create :create_token_for_new_user
  
  
  has_attached_file :profile_image, 
                    #:styles => { :small => "265x"},
                    :url  => "/assets/:id/:basename.:extension",
                    :path => ":rails_root/public/assets/:id/:basename.:extension",
                    :convert_options => {:all => ["-strip", "-colorspace RGB"]}
  
  validates :email, :presence => {:presence => true,:message => "Escribe un email"}#, :if => :enable_email_validations}
  validates :email, :uniqueness => {:uniqueness => true,:message => "Ya existe un usuario con este email"}#,:if => :enable_email_validations}
  validates :email, :format => {:with => /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/,:message => "El email no tiene el formato correcto"}#, :if => :enable_email_validations }

  validates :proxy_password, :presence => {:presence => true,:message => "Escribe una contraseña"}#, :if => :enable_password_validations}
  #validates :proxy_password, :length => { :in => 8..60,:message => "La contraseña debe tener 8 caracteres mínimo", :if => :enable_password_validations }
  #validates :proxy_password, :format => {:with =>  /([a-z]+[A-Z]+[0-9]+|[A-Z]+[a-z]+[0-9]+|[A-Z]+[0-9]+[a-z]+|[0-9]+[a-z]+[A-Z]+|[a-z]+[0-9]+[A-Z]+|[0-9]+[A-Z]+[a-z]+)/,:message => "La contraseña debe tener mínimo una mayúscula, una minúscula y un número", :if => :enable_password_validations }

  
  validates :first_name, :presence => {:presence => true,:message => "Escribe un nombre"}
# validates :last_name, :presence => {:presence => true,:message => "Escribe un apellido"}

  has_many :activities, order: "start desc", dependent: :destroy
  has_and_belongs_to_many :schedule,
                          class_name: "Activity",
                          join_table: "activities_users", 
                          association_foreign_key: "activity_id", 
                          foreign_key: "user_id",
                          order: "start asc"
  
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
  
    def create_token_for_new_user
      self.token = User.generate_access_token
    end
  
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

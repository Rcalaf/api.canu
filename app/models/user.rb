# encoding: UTF-8
class User < ActiveRecord::Base
  attr_accessible :active, :email, :first_name, :last_name, :proxy_password, :password, :salt, :token, :user_name, :profile_image, :latitude, :longitude, :phone_number, :phone_verified
  
  before_validation :downcase_email
  before_create :create_token_for_new_user
  
  
  has_attached_file :profile_image, 
                    :styles => { :thumb => "190x190" },
                    :url  => "/system/:id/:class/:basename.:extension",
                    :path => ":rails_root/public/system/:id/:class/:basename.:extension",
                    :convert_options => {:all => ["-strip", "-colorspace RGB"]}
  
  validates :email, :allow_blank => true,:uniqueness => true, :format => {:with => /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/}
  #validates :email, :uniqueness => true#,:if => :enable_email_validations}
  #validates :email, :format => {:with => /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/}#,:message => "El email no tiene el formato correcto"}#, :if => :enable_email_validations }

  validates :password, :presence => true #, :if => :enable_password_validations}
  #validates :proxy_password_confirmation, :confirmation => true, :on => :edit
  #validates :proxy_password, :length => { :in => 8..60,:message => "La contraseña debe tener 8 caracteres mínimo", :if => :enable_password_validations }
  #validates :proxy_password, :format => {:with =>  /([a-z]+[A-Z]+[0-9]+|[A-Z]+[a-z]+[0-9]+|[A-Z]+[0-9]+[a-z]+|[0-9]+[a-z]+[A-Z]+|[a-z]+[0-9]+[A-Z]+|[0-9]+[A-Z]+[a-z]+)/,:message => "La contraseña debe tener mínimo una mayúscula, una minúscula y un número", :if => :enable_password_validations }
  
  validates :user_name, :presence => true
  validates :user_name, :uniqueness => true
  validates :user_name, format: { with: /\A[a-zA-Z0-9]+\Z/ }
  
  
  #validates :first_name, :presence => true
  #validates :last_name, :presence => true

  # validates :phone_number, :uniqueness => true

  #has_many :api_keys, order: "created_at asc", dependent: :destroy
  has_many :devices, dependent: :destroy
  has_many :activities, order: "start asc", dependent: :destroy
  has_and_belongs_to_many :schedule,
                          class_name: "Activity",
                          join_table: "activities_users", 
                          association_foreign_key: "activity_id", 
                          foreign_key: "user_id",
                          order: "start asc"
  has_many :messages, order: "created_at asc", dependent: :destroy

  belongs_to :ghostuser

  has_many :invitation_lists

  has_many :notifications, dependent: :destroy

  has_and_belongs_to_many :schedule_invitation,
                          class_name: "InvitationList",
                          join_table: "invitation_lists_users", 
                          association_foreign_key: "invitation_list_id", 
                          foreign_key: "user_id"
                          
   scope :in_range, (lambda do |latitude,longitude|  
          latitude_range_up = latitude + Activity::RANGE
          latitude_range_down = latitude - Activity::RANGE
          longitude_range_up = longitude + Activity::RANGE
          longitude_range_down = longitude - Activity::RANGE   
          where('latitude < ? AND latitude > ? AND longitude < ? AND longitude > ?',latitude_range_up,latitude_range_down,longitude_range_up,longitude_range_down) 
          end)

   scope :privacy_location, lambda{ |private_location| where('private_location = ?', private_location) }
  
  def proxy_password
    @proxy_password
  end
  
  def proxy_password=(pwd)
    @proxy_password = pwd
    return if pwd.blank?
    create_new_salt
    self.password = User.encrypted_password(self.proxy_password, self.salt)
  end
  
  def self.authenticate(id,password)
    user = User.find_by_email(id.downcase) || User.find_by_user_name(id)
    if user
      expected_password = encrypted_password(password,user.salt)
      puts expected_password
      if user.password != expected_password
        user.errors.add :password, "password wrong"
      else
        user.update_attribute(:token, User.generate_access_token)
        #ApiKey.create(user_id: user.id) if user.api_keys.empty?
      end
    else
      user = User.new
      user.errors.add :email, "email or password wrong"
    end
    user
  end
  
  def mail_verification_token
    Digest::SHA1.hexdigest(self.id.to_s + salt + self.email)
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
      if !self.email.nil?
        self.email = self.email.downcase
      end
   end

   def self.encrypted_password(proxy_password,salt)
     string_to_hash = proxy_password + "gettogether" + salt
     Digest::SHA1.hexdigest(string_to_hash)
   end

   def create_new_salt
     self.salt = self.object_id.to_s + rand.to_s
   end

end

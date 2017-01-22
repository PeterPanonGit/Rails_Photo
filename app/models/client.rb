class Client < ActiveRecord::Base
  include ConstHelper
  has_many :queue_images
  has_many :likes
  mount_uploader :avatar, AvatarUploader
  # Include default devise modules. Others available are:
  # :, :lockable, :timeoutable and :omniauthable :confirmable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :validatable, :lockable, :omniauthable, :omniauth_providers => [:google_oauth2, :facebook, :twitter]
  validates :name, presence: true
  # Now we can get names from social networks so it might not be unique (delete these lines when you read it)
  #validates :name, uniqueness: true, if: -> { self.name.present? }
  validates :avatar, presence: true
  #before_save {|r| r.lastprocess = Time.now}

  def user?
    role_id.nil? || role_id == CLIENT_TYPE_USER
  end

  def admin?
    !role_id.nil? && role_id == CLIENT_TYPE_ADMIN
  end

  def self.from_omniauth(auth)
    @client = where(provider: auth.provider, uid: auth.uid).first
    unless @client
      @client = Client.new
      @client.provider = auth.provider
      @client.uid = auth.uid
      @client.email = auth.info.email || ""
      @client.encrypted_password = Devise.friendly_token[0,20]
      @client.name = auth.info.name
      @client.save(validate: false)
      #updating avatar manualy because or CarrierWave will make it nil
      @client.update_attribute :avatar, auth.info.image || AvatarUploader.default_url
    end
    @client
  end

  private

end

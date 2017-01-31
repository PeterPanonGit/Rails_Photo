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
    if @client
      @client.name = auth.info.name
      @client.remote_avatar = get_avatar auth.info.image
      @client.save(validate: false)
    else
      @client = Client.new(
          provider: auth.provider,
          uid: auth.uid,
          email: auth.info.email || "",
          encrypted_password: Devise.friendly_token[0,20],
          name: auth.info.name,
          remote_avatar: get_avatar(auth.info.image),
        )
      @client.save(validate: false)
    end
    @client
  end

  def self.get_avatar url
    if !url || url.include?("default_profile") || url.include?("/AAAAAAAAAAA/4252rscbv5M/photo.jpg") || url.include?("/v2.6/1630162470620075/picture")
      nil
    else
      url
    end
  end

  def reached_maximum?
    QueueImage.maximum_per_client <= queue_images.where(is_premium: false).count
  end

  def delete_older_image
    qi = queue_images.where(is_premium: false).order(created_at: :desc).last
    content = qi.content
    content.remove_image!
    content.destroy if content.save
  end

  private

end

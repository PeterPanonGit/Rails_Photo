class Content < ActiveRecord::Base
  has_many :queue_images, dependent: :destroy
  mount_uploader :image, ImageUploader
end

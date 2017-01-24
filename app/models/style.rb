class Style < ActiveRecord::Base
	acts_as_taggable
  has_many :queue_images
  mount_uploader :image, ImageUploader
end

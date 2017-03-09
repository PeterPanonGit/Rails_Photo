class QueueImage < ActiveRecord::Base
  has_many :pimages , dependent: :destroy
  belongs_to :client
  belongs_to :content
  belongs_to :style
  has_many :likes, foreign_key: "queue_id"
  #mount_uploader :content_image, AvatarUploader
  #mount_uploader :style_image, AvatarUploader
  scope :last_n_days, lambda {|d|  where('ftime > ?' , Time.now - d.days)}

  validate :has_credits, on: :create

  @@maximum_per_client = 25


  # I believe you can replace the whole method by distance_of_time_in_words
  def time_ago
    return '' if updated_at.nil?
    t_ago = (Time.now - updated_at)/60


    return 'сейчас' if t_ago < 1
    str = "#{t_ago.to_i} м"
    t_ago = (t_ago/60)
    if t_ago < 1
      return str
    else
      str = "#{t_ago.to_i} ч"
    end
    t_ago = (t_ago/24)
    if t_ago < 1
      return str
    else
      str = "#{t_ago.to_i} д"
    end
    t_ago = (t_ago/30)
    if t_ago < 1
      return str
    else
      str = "#{t_ago.to_i} м"
    end
    t_ago = (t_ago/12)
    if t_ago < 1
      return str
    else
      str = "#{t_ago.to_i} г"
    end
    str
  end

  def result_image
    if pimages.count > 0
      pimages.all.order('created_at DESC').first
    end
  end

  def self.maximum_per_client
    @@maximum_per_client
  end

  def has_credits
    if is_premium
      errors.add(:credits, 'You have not enough credits') unless client.has_credits
    end
  end
end

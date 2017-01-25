class AddIsPremiumToQueueImages < ActiveRecord::Migration
  def change
    add_column :queue_images, :is_premium, :boolean, :default => false
  end
end

class AddMixingLevelToQueueImages < ActiveRecord::Migration
  def change
    add_column :queue_images, :mixing_level, :string
  end
end

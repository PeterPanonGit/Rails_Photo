class AllowContentImageNull < ActiveRecord::Migration
  def change
    change_column :contents, :image, :string, :null => true
  end
end

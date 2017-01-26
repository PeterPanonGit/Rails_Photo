class AllowClientAvatarNull < ActiveRecord::Migration
  def change
  	change_column :clients, :avatar, :string, :null => true
  end
end

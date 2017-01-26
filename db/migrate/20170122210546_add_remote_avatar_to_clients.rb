class AddRemoteAvatarToClients < ActiveRecord::Migration
  def change
  	add_column :clients, :remote_avatar, :string
  end
end

class AddLastActiveAtToClients < ActiveRecord::Migration
  def change
    add_column :clients, :last_active_at, :datetime, default: 0
  end
end

class AddCreditsToClients < ActiveRecord::Migration
  def change
    add_column :clients, :credits, :integer, default: 5
  end
end

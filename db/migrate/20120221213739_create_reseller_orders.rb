class CreateResellerOrders < ActiveRecord::Migration
  def self.up
    create_table :reseller_orders do |t|
      t.string :url
      t.timestamps
    end
  end

  def self.down
    drop_table :reseller_orders
  end
end

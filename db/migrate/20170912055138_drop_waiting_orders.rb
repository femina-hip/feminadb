class DropWaitingOrders < ActiveRecord::Migration[5.1]
  def up
    drop_table(:waiting_orders)
  end
end

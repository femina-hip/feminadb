class AddStandingOrderCreatedAt < ActiveRecord::Migration
  def self.up
    add_column(:standing_orders, :created_at, :datetime)

    all_rows = select_all("SELECT versioned_id, MIN(created_at) AS created_at FROM versions WHERE versioned_type = 'StandingOrder' GROUP BY versioned_id")

    all_rows.each do |row|
      versioned_id = row['versioned_id']
      created_at = row['created_at']
      execute("UPDATE standing_orders SET created_at = '#{created_at}' WHERE id = #{versioned_id}")
    end
  end

  def self.down
    remove_column(:standing_orders, :created_at)
  end
end
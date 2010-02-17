class CreateWarehouses < ActiveRecord::Migration
  def self.up
    create_table :warehouses do |t|
      t.column :name, :string
      t.column :comment, :string
    end

    Warehouse.create :name => "Chang'ombe",
        :comment => 'for internal distribution'
    Warehouse.create :name => 'Gerezani',
        :comment => 'for up-country distribution'
  end

  def self.down
    drop_table :warehouses
  end
end

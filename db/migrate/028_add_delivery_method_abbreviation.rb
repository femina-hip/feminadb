class AddDeliveryMethodAbbreviation < ActiveRecord::Migration
  def self.up
    add_column :delivery_methods, :abbreviation, :string, :null => false

    [['Dar es Salaam', 'DSM'], ['Up-Country', 'UC'], ['Up-Country Corporate', 'UCC']].each do |name, abbreviation|
      dm = DeliveryMethod.find_by_name(name)
      dm.abbreviation = abbreviation
      dm.save!
    end
  end

  def self.down
    remove_column :delivery_methods, :abbreviation
  end
end

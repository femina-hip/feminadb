class CreateRequestStatuses < ActiveRecord::Migration
  def self.up
    create_table :request_statuses do |t|
      t.column :name, :string
    end
    RequestStatus.enumeration_model_updates_permitted = true
    RequestStatus.create :name => 'New'
    RequestStatus.create :name => 'Printed'
    RequestStatus.create :name => 'Being Delivered'
    RequestStatus.create :name => 'Delivered (unconfirmed)'
    RequestStatus.create :name => 'Delivered (confirmed)'
    RequestStatus.create :name => 'Lost'
  end

  def self.down
    drop_table :request_statuses
  end
end

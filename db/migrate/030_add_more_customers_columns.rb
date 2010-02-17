class AddMoreCustomersColumns < ActiveRecord::Migration
  @new_columns = [
    [ :full_name, :string, nil ],
    [ :contact_position, :string, nil ],
    [ :telephone_1, :string, nil ],
    [ :telephone_2, :string, nil ],
    [ :telephone_3, :string, nil ],
    [ :fax, :string, nil ],
    [ :email_1, :string, nil ],
    [ :email_2, :string, nil ],
    [ :website, :string, nil ],
    [ :po_box, :string, nil ],
  ]
  @old_columns = [
    [ :contact_details, :string, nil ],
    [ :location, :string, nil ],
    [ :email, :string, nil ]
  ]

  def self.up
    @new_columns.each do |name, type, default|
      add_column :customers, name, type, :default => default
      add_column :customer_versions, name, type, :default => default
    end
    @old_columns.each do |name, type, default|
      remove_column :customers, name
      remove_column :customer_versions, name
    end
  end

  def self.down
    @new_columns.each do |name, type, default|
      remove_column :customers, name
      remove_column :customer_versions, name
    end
    @old_columns.each do |name, type, default|
      add_column :customers, name, type, :default => default
      add_column :customer_versions, name, type, :default => default
    end
  end
end

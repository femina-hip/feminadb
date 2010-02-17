class CreateClubs < ActiveRecord::Migration
  def self.up
    create_table :clubs do |t|
      t.integer :customer_id, :null => false
      t.string :name, :null => false
      t.string :address, :null => false, :default => ''
      t.string :telephone_1, :null => false, :default => ''
      t.string :telephone_2, :null => false, :default => ''
      t.string :email, :null => false, :default => ''
      t.integer :num_members, :null => false, :default => 0
      t.date :date_founded
      t.string :motto, :null => false, :default => ''
      t.string :objective, :null => false, :default => ''
      t.string :eligibility, :null => false, :default => ''
      t.string :work_plan, :null => false, :default => ''
      t.string :form_submitter_position, :null => false, :default => ''
      t.string :patron, :null => false, :default => ''
      t.text :intended_duty, :null => false, :default => ''
      t.string :founding_motivation, :null => false, :default => ''
      t.text :cooperation_ideas, :null => false, :default => ''

      t.column :updated_at, :datetime, :null => false
      t.column :updated_by, :integer, :null => false
      t.column :version, :integer, :null => false
      t.column :deleted_at, :datetime
    end
    Club.create_versioned_table
  end

  def self.down
    Club.drop_versioned_table
    drop_table :clubs
  end
end

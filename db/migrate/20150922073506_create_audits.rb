class CreateAudits < ActiveRecord::Migration
  def change
    create_table :audits do |t|
      t.datetime :created_at, null: false
      t.string :user_email, null: false
      t.string :table_name, null: false
      t.integer :record_id # may be null, in the case of associations
      t.string :action, null: false # [ create, destroy, update ]
      t.text :before, null: false # empty hash means nonexistent
      t.text :after, null: false # empty hash means nonexistent

      t.index [ :table_name, :record_id ]
    end
  end
end

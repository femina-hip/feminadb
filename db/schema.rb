# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100430122423) do

  create_table "bulk_order_creators", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "from_publication_id"
    t.integer  "from_issue_id"
    t.string   "search_string"
    t.boolean  "constant_num_copies"
    t.integer  "num_copies"
    t.string   "comment"
    t.integer  "delivery_method_id"
    t.date     "order_date"
    t.integer  "created_by"
    t.datetime "created_at"
    t.datetime "deleted_at"
    t.string   "status"
    t.datetime "updated_at"
  end

  add_index "bulk_order_creators", ["issue_id"], :name => "index_bulk_order_creators_on_issue_id"

  create_table "clubs", :force => true do |t|
    t.integer  "customer_id",                         :null => false
    t.string   "name",                                :null => false
    t.string   "address",             :default => "", :null => false
    t.string   "telephone_1",         :default => "", :null => false
    t.string   "telephone_2",         :default => "", :null => false
    t.string   "email",               :default => "", :null => false
    t.integer  "num_members",         :default => 0,  :null => false
    t.date     "date_founded"
    t.string   "motto",               :default => "", :null => false
    t.string   "objective",           :default => "", :null => false
    t.string   "eligibility",         :default => "", :null => false
    t.string   "work_plan",           :default => "", :null => false
    t.string   "patron",              :default => "", :null => false
    t.text     "intended_duty",                       :null => false
    t.string   "founding_motivation", :default => "", :null => false
    t.text     "cooperation_ideas",                   :null => false
    t.datetime "deleted_at"
    t.datetime "created_at"
  end

  create_table "customer_notes", :force => true do |t|
    t.integer  "customer_id"
    t.text     "note",        :limit => 16777215
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "deleted_at"
  end

  add_index "customer_notes", ["customer_id"], :name => "index_customer_notes_on_customer_id"

  create_table "customer_types", :force => true do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.string   "description", :default => "",        :null => false
    t.string   "category",    :default => "Unknown", :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.integer  "customer_type_id"
    t.integer  "region_id"
    t.string   "district"
    t.string   "contact_name"
    t.string   "deliver_via"
    t.integer  "delivery_method_id"
    t.string   "address"
    t.datetime "deleted_at"
    t.string   "full_name"
    t.string   "contact_position"
    t.string   "telephone_1"
    t.string   "telephone_2"
    t.string   "telephone_3"
    t.string   "fax"
    t.string   "email_1"
    t.string   "email_2"
    t.string   "website"
    t.string   "po_box"
    t.string   "route",              :default => "", :null => false
    t.datetime "created_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "delivery_methods", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "deleted_at"
    t.string   "abbreviation",                                            :null => false
    t.integer  "warehouse_id"
    t.boolean  "include_in_distribution_quote_request", :default => true, :null => false
  end

  create_table "districts", :force => true do |t|
    t.integer  "region_id",  :null => false
    t.string   "name",       :null => false
    t.string   "color",      :null => false
    t.datetime "deleted_at"
  end

  create_table "issue_box_sizes", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "num_copies"
    t.datetime "deleted_at"
  end

  create_table "issue_notes", :force => true do |t|
    t.integer  "issue_id",   :null => false
    t.text     "note",       :null => false
    t.datetime "created_at", :null => false
    t.integer  "created_by"
    t.datetime "deleted_at"
  end

  add_index "issue_notes", ["issue_id"], :name => "index_issue_notes_on_issue_id"

  create_table "issues", :force => true do |t|
    t.string   "name"
    t.integer  "publication_id"
    t.date     "issue_date"
    t.datetime "deleted_at"
    t.string   "issue_number",                                  :default => "", :null => false
    t.integer  "quantity",                                      :default => 0,  :null => false
    t.decimal  "price",          :precision => 12, :scale => 0
    t.string   "packing_hints"
  end

  create_table "orders", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "issue_id"
    t.integer  "standing_order_id"
    t.integer  "num_copies"
    t.string   "comments"
    t.date     "order_date"
    t.integer  "region_id"
    t.string   "district"
    t.string   "customer_name"
    t.string   "deliver_via"
    t.integer  "delivery_method_id"
    t.string   "contact_name"
    t.string   "contact_details"
    t.datetime "deleted_at"
  end

  add_index "orders", ["customer_id"], :name => "index_orders_on_customer_id"
  add_index "orders", ["issue_id"], :name => "index_orders_on_issue_id"
  add_index "orders", ["standing_order_id", "issue_id", "deleted_at"], :name => "index_orders_on_standing_order_id_and_issue_id_and_deleted_at"

  create_table "publications", :force => true do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.boolean  "tracks_standing_orders", :default => true, :null => false
    t.boolean  "pr_material",            :default => true
    t.string   "packing_hints"
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.integer  "population"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "deleted_at"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.datetime "deleted_at"
  end

  add_index "roles_users", ["role_id"], :name => "index_roles_users_on_role_id"
  add_index "roles_users", ["user_id"], :name => "index_roles_users_on_user_id"

  create_table "standing_orders", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "publication_id"
    t.integer  "num_copies"
    t.string   "comments"
    t.datetime "deleted_at"
    t.datetime "created_at"
  end

  add_index "standing_orders", ["customer_id", "publication_id"], :name => "index_standing_orders_on_customer_id_and_publication_id"
  add_index "standing_orders", ["customer_id"], :name => "index_standing_orders_on_customer_id"
  add_index "standing_orders", ["publication_id"], :name => "index_standing_orders_on_publication_id"

  create_table "tags", :force => true do |t|
    t.string  "name",                         :null => false
    t.integer "num_customers", :default => 0, :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.datetime "deleted_at"
  end

  create_table "versions", :force => true do |t|
    t.integer  "versioned_id"
    t.string   "versioned_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "user_name"
    t.text     "changes"
    t.integer  "number"
    t.string   "tag"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["versioned_id", "versioned_type", "number"], :name => "index_versions_on_versioned_id_and_versioned_type_and_number"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

  create_table "waiting_orders", :force => true do |t|
    t.integer  "customer_id",                    :null => false
    t.integer  "publication_id",                 :null => false
    t.integer  "num_copies",                     :null => false
    t.string   "comments",       :default => "", :null => false
    t.datetime "deleted_at"
    t.date     "request_date",                   :null => false
  end

  add_index "waiting_orders", ["customer_id"], :name => "index_waiting_orders_on_customer_id"
  add_index "waiting_orders", ["publication_id"], :name => "index_waiting_orders_on_publication_id"

  create_table "warehouses", :force => true do |t|
    t.string "name"
    t.string "comment"
  end

end

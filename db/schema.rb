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

ActiveRecord::Schema.define(:version => 20100321234420) do

  create_table "club_versions", :force => true do |t|
    t.integer  "club_id"
    t.integer  "version"
    t.integer  "customer_id"
    t.string   "name",                    :default => ""
    t.string   "address",                 :default => ""
    t.string   "telephone_1",             :default => ""
    t.string   "telephone_2",             :default => ""
    t.string   "email",                   :default => ""
    t.integer  "num_members",             :default => 0
    t.date     "date_founded"
    t.string   "motto",                   :default => ""
    t.string   "objective",               :default => ""
    t.string   "eligibility",             :default => ""
    t.string   "work_plan",               :default => ""
    t.string   "form_submitter_position", :default => ""
    t.string   "patron",                  :default => ""
    t.text     "intended_duty"
    t.string   "founding_motivation",     :default => ""
    t.text     "cooperation_ideas"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
  end

  create_table "clubs", :force => true do |t|
    t.integer  "customer_id",                             :null => false
    t.string   "name",                                    :null => false
    t.string   "address",                 :default => "", :null => false
    t.string   "telephone_1",             :default => "", :null => false
    t.string   "telephone_2",             :default => "", :null => false
    t.string   "email",                   :default => "", :null => false
    t.integer  "num_members",             :default => 0,  :null => false
    t.date     "date_founded"
    t.string   "motto",                   :default => "", :null => false
    t.string   "objective",               :default => "", :null => false
    t.string   "eligibility",             :default => "", :null => false
    t.string   "work_plan",               :default => "", :null => false
    t.string   "form_submitter_position", :default => "", :null => false
    t.string   "patron",                  :default => "", :null => false
    t.text     "intended_duty",                           :null => false
    t.string   "founding_motivation",     :default => "", :null => false
    t.text     "cooperation_ideas",                       :null => false
    t.datetime "updated_at",                              :null => false
    t.integer  "updated_by",                              :null => false
    t.integer  "version"
    t.datetime "deleted_at"
  end

  create_table "customer_notes", :force => true do |t|
    t.integer  "customer_id"
    t.text     "note",        :limit => 16777215
    t.datetime "created_at"
    t.integer  "created_by"
    t.datetime "deleted_at"
  end

  add_index "customer_notes", ["customer_id"], :name => "index_customer_notes_on_customer_id"

  create_table "customer_type_versions", :force => true do |t|
    t.integer  "customer_type_id"
    t.integer  "version"
    t.string   "name"
    t.datetime "deleted_at"
    t.string   "description",      :default => ""
    t.string   "category",         :default => "Unknown"
    t.datetime "updated_at"
    t.integer  "updated_by"
  end

  create_table "customer_types", :force => true do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.string   "description", :default => "",        :null => false
    t.string   "category",    :default => "Unknown", :null => false
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "version"
  end

  create_table "customer_versions", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "version"
    t.string   "name"
    t.integer  "customer_type_id"
    t.integer  "region_id"
    t.string   "district"
    t.datetime "updated_at"
    t.integer  "updated_by"
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
  end

  create_table "customers", :force => true do |t|
    t.string   "name"
    t.integer  "customer_type_id"
    t.integer  "region_id"
    t.string   "district"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "version"
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
  end

  create_table "delivery_methods", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "deleted_at"
    t.string   "abbreviation",                                            :null => false
    t.integer  "warehouse_id"
    t.boolean  "include_in_distribution_quote_request", :default => true, :null => false
  end

  create_table "district_versions", :force => true do |t|
    t.integer  "district_id"
    t.integer  "version"
    t.integer  "region_id"
    t.string   "name",        :default => ""
    t.string   "color",       :default => ""
    t.datetime "updated_at"
    t.string   "updated_by",  :default => ""
    t.datetime "deleted_at"
  end

  create_table "districts", :force => true do |t|
    t.integer  "region_id",  :null => false
    t.string   "name",       :null => false
    t.string   "color",      :null => false
    t.datetime "updated_at", :null => false
    t.string   "updated_by", :null => false
    t.integer  "version"
    t.datetime "deleted_at"
  end

  create_table "issue_box_size_versions", :force => true do |t|
    t.integer  "issue_box_size_id"
    t.integer  "version"
    t.integer  "issue_id"
    t.integer  "num_copies"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
  end

  create_table "issue_box_sizes", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "num_copies"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "version"
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

  create_table "issue_versions", :force => true do |t|
    t.integer  "issue_id"
    t.integer  "version"
    t.string   "name"
    t.integer  "publication_id"
    t.date     "issue_date"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.string   "issue_number",              :default => "",   :null => false
    t.integer  "quantity",                  :default => 0,    :null => false
    t.integer  "num_copies_in_house",       :default => 0,    :null => false
    t.boolean  "allows_new_special_orders", :default => true, :null => false
    t.string   "inventory_comment",         :default => "",   :null => false
  end

  create_table "issues", :force => true do |t|
    t.string   "name"
    t.integer  "publication_id"
    t.date     "issue_date"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "version"
    t.datetime "deleted_at"
    t.string   "issue_number",              :default => "",   :null => false
    t.integer  "quantity",                  :default => 0,    :null => false
    t.integer  "num_copies_in_house",       :default => 0,    :null => false
    t.boolean  "allows_new_special_orders", :default => true, :null => false
    t.string   "inventory_comment",         :default => "",   :null => false
  end

  create_table "order_versions", :force => true do |t|
    t.integer  "order_id"
    t.integer  "version"
    t.integer  "customer_id"
    t.integer  "issue_id"
    t.integer  "standing_order_id"
    t.integer  "num_copies"
    t.string   "comments"
    t.date     "order_date"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "region_id"
    t.string   "district"
    t.string   "customer_name"
    t.string   "deliver_via"
    t.integer  "delivery_method_id"
    t.string   "contact_name"
    t.string   "contact_details"
    t.datetime "deleted_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "issue_id"
    t.integer  "standing_order_id"
    t.integer  "num_copies"
    t.string   "comments"
    t.date     "order_date"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "version"
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

  create_table "publication_versions", :force => true do |t|
    t.integer  "publication_id"
    t.integer  "version"
    t.string   "name"
    t.datetime "updated_at"
    t.string   "updated_by"
    t.datetime "deleted_at"
    t.boolean  "tracks_standing_orders", :default => true, :null => false
  end

  create_table "publications", :force => true do |t|
    t.string   "name"
    t.datetime "updated_at"
    t.string   "updated_by"
    t.integer  "version"
    t.datetime "deleted_at"
    t.boolean  "tracks_standing_orders", :default => true, :null => false
  end

  create_table "region_versions", :force => true do |t|
    t.integer  "region_id"
    t.integer  "version"
    t.string   "name"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.integer  "population"
  end

  create_table "regions", :force => true do |t|
    t.string   "name"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "version"
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

  create_table "special_order_line_versions", :force => true do |t|
    t.integer  "special_order_line_id"
    t.integer  "version"
    t.integer  "special_order_id"
    t.integer  "issue_id"
    t.integer  "num_copies_requested"
    t.integer  "num_copies"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
  end

  create_table "special_order_lines", :force => true do |t|
    t.integer  "special_order_id",     :null => false
    t.integer  "issue_id",             :null => false
    t.integer  "num_copies_requested", :null => false
    t.integer  "num_copies"
    t.datetime "updated_at",           :null => false
    t.integer  "updated_by"
    t.integer  "version"
    t.datetime "deleted_at"
  end

  add_index "special_order_lines", ["issue_id"], :name => "index_special_order_lines_on_issue_id"

  create_table "special_order_notes", :force => true do |t|
    t.integer  "special_order_id", :null => false
    t.text     "note",             :null => false
    t.datetime "created_at",       :null => false
    t.integer  "created_by"
    t.datetime "deleted_at"
  end

  add_index "special_order_notes", ["special_order_id"], :name => "index_special_order_notes_on_special_order_id"

  create_table "special_order_versions", :force => true do |t|
    t.integer  "special_order_id"
    t.integer  "version"
    t.integer  "customer_id",        :default => 0
    t.string   "customer_name",      :default => ""
    t.string   "reason",             :default => ""
    t.datetime "requested_at"
    t.date     "requested_for_date"
    t.string   "received_by",        :default => ""
    t.integer  "authorized_by"
    t.datetime "authorized_at"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.integer  "requested_by",       :default => 0,     :null => false
    t.string   "authorize_comments", :default => "",    :null => false
    t.boolean  "approved",           :default => false, :null => false
    t.integer  "completed_by"
    t.datetime "completed_at"
  end

  create_table "special_orders", :force => true do |t|
    t.integer  "customer_id"
    t.string   "customer_name",      :default => "",    :null => false
    t.string   "reason",             :default => "",    :null => false
    t.datetime "requested_at",                          :null => false
    t.date     "requested_for_date",                    :null => false
    t.string   "received_by",        :default => "",    :null => false
    t.integer  "authorized_by"
    t.datetime "authorized_at"
    t.datetime "updated_at",                            :null => false
    t.integer  "updated_by"
    t.integer  "version"
    t.datetime "deleted_at"
    t.integer  "requested_by",       :default => 0,     :null => false
    t.string   "authorize_comments", :default => "",    :null => false
    t.boolean  "approved",           :default => false, :null => false
    t.integer  "completed_by"
    t.datetime "completed_at"
  end

  add_index "special_orders", ["customer_id"], :name => "index_special_orders_on_customer_id"

  create_table "standing_order_versions", :force => true do |t|
    t.integer  "standing_order_id"
    t.integer  "version"
    t.integer  "customer_id"
    t.integer  "publication_id"
    t.integer  "num_copies"
    t.string   "comments"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
  end

  create_table "standing_orders", :force => true do |t|
    t.integer  "customer_id"
    t.integer  "publication_id"
    t.integer  "num_copies"
    t.string   "comments"
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.integer  "version"
    t.datetime "deleted_at"
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

  add_index "versions", ["created_at"], :name => "index_versions_on_created_at"
  add_index "versions", ["number"], :name => "index_versions_on_number"
  add_index "versions", ["tag"], :name => "index_versions_on_tag"
  add_index "versions", ["user_id", "user_type"], :name => "index_versions_on_user_id_and_user_type"
  add_index "versions", ["user_name"], :name => "index_versions_on_user_name"
  add_index "versions", ["versioned_id", "versioned_type"], :name => "index_versions_on_versioned_id_and_versioned_type"

  create_table "waiting_order_versions", :force => true do |t|
    t.integer  "waiting_order_id"
    t.integer  "version"
    t.integer  "customer_id"
    t.integer  "publication_id"
    t.integer  "num_copies"
    t.string   "comments",         :default => ""
    t.datetime "updated_at"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.date     "request_date",                     :null => false
  end

  create_table "waiting_orders", :force => true do |t|
    t.integer  "customer_id",                    :null => false
    t.integer  "publication_id",                 :null => false
    t.integer  "num_copies",                     :null => false
    t.string   "comments",       :default => "", :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "updated_by",                     :null => false
    t.integer  "version"
    t.datetime "deleted_at"
    t.date     "request_date",                   :null => false
  end

  create_table "warehouse_issue_box_size_versions", :force => true do |t|
    t.integer  "warehouse_issue_box_size_id"
    t.integer  "version"
    t.integer  "warehouse_id"
    t.integer  "issue_box_size_id"
    t.integer  "num_boxes",                   :default => 0, :null => false
    t.integer  "updated_by"
    t.datetime "updated_at"
    t.datetime "deleted_at"
  end

  create_table "warehouse_issue_box_sizes", :force => true do |t|
    t.integer  "warehouse_id"
    t.integer  "issue_box_size_id"
    t.integer  "num_boxes",         :default => 0, :null => false
    t.integer  "updated_by"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.integer  "version"
  end

  create_table "warehouses", :force => true do |t|
    t.string  "name"
    t.string  "comment"
    t.boolean "tracks_inventory", :default => true, :null => false
  end

end

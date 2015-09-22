# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150922073506) do

  create_table "audits", force: :cascade do |t|
    t.datetime "created_at",               null: false
    t.string   "user_email", limit: 255,   null: false
    t.string   "table_name", limit: 255,   null: false
    t.integer  "record_id",  limit: 4
    t.string   "action",     limit: 255,   null: false
    t.text     "before",     limit: 65535, null: false
    t.text     "after",      limit: 65535, null: false
  end

  add_index "audits", ["table_name", "record_id"], name: "index_audits_on_table_name_and_record_id", using: :btree

  create_table "bulk_order_creators", force: :cascade do |t|
    t.integer  "issue_id",            limit: 4
    t.integer  "from_publication_id", limit: 4
    t.integer  "from_issue_id",       limit: 4
    t.string   "search_string",       limit: 255
    t.boolean  "constant_num_copies"
    t.integer  "num_copies",          limit: 4
    t.string   "comment",             limit: 255
    t.integer  "delivery_method_id",  limit: 4
    t.date     "order_date"
    t.integer  "created_by",          limit: 4
    t.datetime "created_at"
    t.datetime "deleted_at"
    t.string   "status",              limit: 255
    t.datetime "updated_at"
  end

  add_index "bulk_order_creators", ["issue_id"], name: "index_bulk_order_creators_on_issue_id", using: :btree

  create_table "clubs", force: :cascade do |t|
    t.integer  "customer_id",         limit: 4,                  null: false
    t.string   "name",                limit: 255,                null: false
    t.string   "address",             limit: 255,   default: "", null: false
    t.string   "telephone_1",         limit: 255,   default: "", null: false
    t.string   "telephone_2",         limit: 255,   default: "", null: false
    t.string   "email",               limit: 255,   default: "", null: false
    t.integer  "num_members",         limit: 4,     default: 0,  null: false
    t.date     "date_founded"
    t.string   "motto",               limit: 255,   default: "", null: false
    t.string   "objective",           limit: 255,   default: "", null: false
    t.string   "eligibility",         limit: 255,   default: "", null: false
    t.string   "work_plan",           limit: 255,   default: "", null: false
    t.string   "patron",              limit: 255,   default: "", null: false
    t.text     "intended_duty",       limit: 65535,              null: false
    t.string   "founding_motivation", limit: 255,   default: "", null: false
    t.text     "cooperation_ideas",   limit: 65535,              null: false
    t.datetime "deleted_at"
    t.datetime "created_at"
  end

  create_table "customer_notes", force: :cascade do |t|
    t.integer  "customer_id", limit: 4
    t.text     "note",        limit: 16777215
    t.datetime "created_at"
    t.integer  "created_by",  limit: 4
    t.datetime "deleted_at"
  end

  add_index "customer_notes", ["customer_id"], name: "index_customer_notes_on_customer_id", using: :btree

  create_table "customer_types", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.datetime "deleted_at"
    t.string   "description", limit: 255, default: "",        null: false
    t.string   "category",    limit: 255, default: "Unknown", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.integer  "customer_type_id",   limit: 4
    t.integer  "region_id",          limit: 4
    t.string   "district",           limit: 255
    t.string   "contact_name",       limit: 255
    t.string   "deliver_via",        limit: 255
    t.integer  "delivery_method_id", limit: 4
    t.string   "address",            limit: 255
    t.datetime "deleted_at"
    t.string   "full_name",          limit: 255
    t.string   "contact_position",   limit: 255
    t.string   "telephone_1",        limit: 255
    t.string   "telephone_2",        limit: 255
    t.string   "telephone_3",        limit: 255
    t.string   "fax",                limit: 255
    t.string   "email_1",            limit: 255
    t.string   "email_2",            limit: 255
    t.string   "website",            limit: 255
    t.string   "po_box",             limit: 255
    t.string   "route",              limit: 255, default: "", null: false
    t.datetime "created_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "delivery_methods", force: :cascade do |t|
    t.string   "name",                                  limit: 255
    t.string   "description",                           limit: 255
    t.datetime "deleted_at"
    t.string   "abbreviation",                          limit: 255,                null: false
    t.integer  "warehouse_id",                          limit: 4
    t.boolean  "include_in_distribution_quote_request",             default: true, null: false
  end

  create_table "districts", force: :cascade do |t|
    t.integer  "region_id",  limit: 4,   null: false
    t.string   "name",       limit: 255, null: false
    t.string   "color",      limit: 255, null: false
    t.datetime "deleted_at"
  end

  create_table "issue_box_sizes", force: :cascade do |t|
    t.integer  "issue_id",   limit: 4
    t.integer  "num_copies", limit: 4
    t.datetime "deleted_at"
  end

  create_table "issue_notes", force: :cascade do |t|
    t.integer  "issue_id",   limit: 4,     null: false
    t.text     "note",       limit: 65535, null: false
    t.datetime "created_at",               null: false
    t.integer  "created_by", limit: 4
    t.datetime "deleted_at"
  end

  add_index "issue_notes", ["issue_id"], name: "index_issue_notes_on_issue_id", using: :btree

  create_table "issues", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.integer  "publication_id", limit: 4
    t.date     "issue_date"
    t.datetime "deleted_at"
    t.string   "issue_number",   limit: 255,                default: "", null: false
    t.integer  "quantity",       limit: 4,                  default: 0,  null: false
    t.decimal  "price",                      precision: 12
    t.string   "packing_hints",  limit: 255
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "customer_id",        limit: 4
    t.integer  "issue_id",           limit: 4
    t.integer  "standing_order_id",  limit: 4
    t.integer  "num_copies",         limit: 4
    t.string   "comments",           limit: 255
    t.date     "order_date"
    t.integer  "region_id",          limit: 4
    t.string   "district",           limit: 255
    t.string   "customer_name",      limit: 255
    t.string   "deliver_via",        limit: 255
    t.integer  "delivery_method_id", limit: 4
    t.string   "contact_name",       limit: 255
    t.string   "contact_details",    limit: 255
    t.datetime "deleted_at"
  end

  add_index "orders", ["customer_id"], name: "index_orders_on_customer_id", using: :btree
  add_index "orders", ["issue_id"], name: "index_orders_on_issue_id", using: :btree
  add_index "orders", ["standing_order_id", "issue_id", "deleted_at"], name: "index_orders_on_standing_order_id_and_issue_id_and_deleted_at", using: :btree

  create_table "publications", force: :cascade do |t|
    t.string   "name",                   limit: 255
    t.datetime "deleted_at"
    t.boolean  "tracks_standing_orders",             default: true, null: false
    t.boolean  "pr_material",                        default: true
    t.string   "packing_hints",          limit: 255
  end

  create_table "regions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "deleted_at"
    t.integer  "population", limit: 4
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "deleted_at"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer  "role_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "deleted_at"
  end

  add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
  add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

  create_table "standing_orders", force: :cascade do |t|
    t.integer  "customer_id",    limit: 4
    t.integer  "publication_id", limit: 4
    t.integer  "num_copies",     limit: 4
    t.string   "comments",       limit: 255
    t.datetime "deleted_at"
    t.datetime "created_at"
  end

  add_index "standing_orders", ["customer_id", "publication_id"], name: "index_standing_orders_on_customer_id_and_publication_id", using: :btree
  add_index "standing_orders", ["customer_id"], name: "index_standing_orders_on_customer_id", using: :btree
  add_index "standing_orders", ["publication_id"], name: "index_standing_orders_on_publication_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",          limit: 255,             null: false
    t.integer "num_customers", limit: 4,   default: 0, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "login",                     limit: 255
    t.string   "email",                     limit: 255
    t.string   "crypted_password",          limit: 40
    t.string   "salt",                      limit: 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token",            limit: 255
    t.datetime "remember_token_expires_at"
    t.datetime "deleted_at"
  end

  create_table "versions", force: :cascade do |t|
    t.integer  "versioned_id",   limit: 4
    t.string   "versioned_type", limit: 255
    t.integer  "user_id",        limit: 4
    t.string   "user_type",      limit: 255
    t.string   "user_name",      limit: 255
    t.text     "modifications",  limit: 65535
    t.integer  "number",         limit: 4
    t.string   "tag",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "versions", ["versioned_id", "versioned_type", "number"], name: "index_versions_on_versioned_id_and_versioned_type_and_number", using: :btree
  add_index "versions", ["versioned_id", "versioned_type"], name: "index_versions_on_versioned_id_and_versioned_type", using: :btree

  create_table "waiting_orders", force: :cascade do |t|
    t.integer  "customer_id",    limit: 4,                null: false
    t.integer  "publication_id", limit: 4,                null: false
    t.integer  "num_copies",     limit: 4,                null: false
    t.string   "comments",       limit: 255, default: "", null: false
    t.datetime "deleted_at"
    t.date     "request_date",                            null: false
  end

  add_index "waiting_orders", ["customer_id"], name: "index_waiting_orders_on_customer_id", using: :btree
  add_index "waiting_orders", ["publication_id"], name: "index_waiting_orders_on_publication_id", using: :btree

  create_table "warehouses", force: :cascade do |t|
    t.string "name",    limit: 255
    t.string "comment", limit: 255
  end

end

# The back story: our original migrations depended on deprecated Rails plugins.
# It was either fix all those old migrations, or just migrate from scratch. The
# database was down anyway, so migrating from scratch made more sense.
#
# This is essentially a db:schema:dump.
class CreateInitialSchema < ActiveRecord::Migration[4.2]
  def change
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
      t.string   "status",              limit: 255
      t.datetime "updated_at"
    end

    add_index "bulk_order_creators", ["issue_id"], name: "index_bulk_order_creators_on_issue_id", using: :btree

    create_table "customer_notes", force: :cascade do |t|
      t.integer  "customer_id", limit: 4
      t.text     "note",        limit: 16777215
      t.datetime "created_at"
      t.integer  "created_by",  limit: 4
    end

    add_index "customer_notes", ["customer_id"], name: "index_customer_notes_on_customer_id", using: :btree

    create_table "customer_types", force: :cascade do |t|
      t.string "name",        limit: 255
      t.string "description", limit: 255, default: "",        null: false
      t.string "category",    limit: 255, default: "Unknown", null: false
    end

    create_table "customers", force: :cascade do |t|
      t.string   "name",                 limit: 255
      t.integer  "customer_type_id",     limit: 4
      t.integer  "region_id",            limit: 4
      t.string   "district",             limit: 255
      t.string   "contact_name",         limit: 255
      t.integer  "delivery_method_id",   limit: 4
      t.datetime "created_at"
      t.string   "delivery_address",     limit: 512,              null: false
      t.string   "sms_numbers",          limit: 255, default: "", null: false
      t.string   "club_sms_numbers",     limit: 255, default: "", null: false
      t.string   "old_sms_numbers",      limit: 255, default: "", null: false
      t.string   "old_club_sms_numbers", limit: 255, default: "", null: false
      t.string   "other_contacts",       limit: 255, default: "", null: false
      t.string   "student_sms_numbers",  limit: 255, default: "", null: false
    end

    create_table "delivery_methods", force: :cascade do |t|
      t.string "name",         limit: 255
      t.string "description",  limit: 255
      t.string "abbreviation", limit: 255, null: false
    end

    create_table "districts", force: :cascade do |t|
      t.integer "region_id", limit: 4,   null: false
      t.string  "name",      limit: 255, null: false
      t.string  "color",     limit: 255, null: false
    end

    create_table "issue_notes", force: :cascade do |t|
      t.integer  "issue_id",   limit: 4,     null: false
      t.text     "note",       limit: 65535, null: false
      t.datetime "created_at",               null: false
      t.integer  "created_by", limit: 4
    end

    add_index "issue_notes", ["issue_id"], name: "index_issue_notes_on_issue_id", using: :btree

    create_table "issues", force: :cascade do |t|
      t.string  "name",           limit: 255
      t.integer "publication_id", limit: 4
      t.date    "issue_date"
      t.string  "issue_number",   limit: 255, default: "", null: false
      t.string  "box_sizes",      limit: 255,              null: false
    end

    create_table "orders", force: :cascade do |t|
      t.integer "customer_id",       limit: 4
      t.integer "issue_id",          limit: 4
      t.integer "standing_order_id", limit: 4
      t.integer "num_copies",        limit: 4
      t.string  "comments",          limit: 255
      t.date    "order_date"
      t.string  "district",          limit: 255
      t.string  "customer_name",     limit: 255
      t.string  "delivery_address",  limit: 512, null: false
      t.string  "contact_details",   limit: 255
      t.string  "region",            limit: 255, null: false
      t.string  "delivery_method",   limit: 255, null: false
    end

    add_index "orders", ["customer_id"], name: "index_orders_on_customer_id", using: :btree
    add_index "orders", ["issue_id"], name: "index_orders_on_issue_id", using: :btree
    add_index "orders", ["standing_order_id", "issue_id"], name: "index_orders_on_standing_order_id_and_issue_id_and_deleted_at", using: :btree

    create_table "publications", force: :cascade do |t|
      t.string  "name",                   limit: 255
      t.boolean "tracks_standing_orders",             default: true, null: false
      t.boolean "pr_material",                        default: true
    end

    create_table "regions", force: :cascade do |t|
      t.string  "name",       limit: 255
      t.integer "population", limit: 4
    end

    create_table "roles", force: :cascade do |t|
      t.string "name", limit: 255
    end

    create_table "roles_users", id: false, force: :cascade do |t|
      t.integer "role_id", limit: 4
      t.integer "user_id", limit: 4
    end

    add_index "roles_users", ["role_id"], name: "index_roles_users_on_role_id", using: :btree
    add_index "roles_users", ["user_id"], name: "index_roles_users_on_user_id", using: :btree

    create_table "standing_orders", force: :cascade do |t|
      t.integer  "customer_id",    limit: 4
      t.integer  "publication_id", limit: 4
      t.integer  "num_copies",     limit: 4
      t.string   "comments",       limit: 255
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
    end

    create_table "waiting_orders", force: :cascade do |t|
      t.integer "customer_id",    limit: 4,                null: false
      t.integer "publication_id", limit: 4,                null: false
      t.integer "num_copies",     limit: 4,                null: false
      t.string  "comments",       limit: 255, default: "", null: false
      t.date    "request_date",                            null: false
    end

    add_index "waiting_orders", ["customer_id"], name: "index_waiting_orders_on_customer_id", using: :btree
    add_index "waiting_orders", ["publication_id"], name: "index_waiting_orders_on_publication_id", using: :btree
  end
end

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

ActiveRecord::Schema.define(version: 20210813183132) do

  create_table "audits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.datetime "created_at", null: false
    t.string "user_email", null: false
    t.string "table_name", null: false
    t.integer "record_id"
    t.string "action", null: false
    t.text "before", limit: 16777215, null: false
    t.text "after", limit: 16777215, null: false
    t.index ["table_name", "record_id"], name: "index_audits_on_table_name_and_record_id", length: { table_name: 191 }
  end

  create_table "bulk_order_creators", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "issue_id"
    t.integer "from_publication_id"
    t.integer "from_issue_id"
    t.string "search_string"
    t.boolean "constant_num_copies"
    t.integer "num_copies"
    t.string "comment"
    t.integer "delivery_method_id"
    t.date "order_date"
    t.integer "created_by"
    t.datetime "created_at"
    t.string "status"
    t.datetime "updated_at"
    t.index ["issue_id"], name: "index_bulk_order_creators_on_issue_id"
  end

  create_table "customer_notes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "customer_id"
    t.text "note", limit: 4294967295
    t.datetime "created_at"
    t.integer "created_by"
    t.index ["customer_id"], name: "index_customer_notes_on_customer_id"
  end

  create_table "customer_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.string "description", default: "", null: false
    t.string "category", default: "Unknown", null: false
  end

  create_table "customers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.integer "customer_type_id"
    t.integer "region_id"
    t.string "council"
    t.string "contact_name"
    t.datetime "created_at"
    t.string "delivery_address", null: false
    t.string "primary_contact_sms_numbers", default: "", null: false
    t.string "club_sms_numbers", default: "", null: false
    t.string "old_sms_numbers", default: "", null: false
    t.string "delivery_contact", default: "", null: false
    t.text "telerivet_id_cache", limit: 16777215
    t.string "headmaster_sms_numbers"
    t.boolean "secondary_school_levels_a", default: false, null: false, comment: "If True, teaches A-level; if _a and _o are both False, unknown"
    t.boolean "secondary_school_levels_o", default: false, null: false, comment: "If True, teaches O-level; if _a and _o are both False, unknown"
    t.boolean "secondary_school_residence_boarding", default: false, null: false, comment: "If True, some students board; if _boarding and _day are both False, unknown"
    t.boolean "secondary_school_residence_day", default: false, null: false, comment: "If True, some students go home at night; if _boarding and _day are both False, unknown"
    t.boolean "secondary_school_sexes_boys", default: false, null: false, comment: "If True, some students are boys; if _boys and _girls are both False, unknown"
    t.boolean "secondary_school_sexes_girls", default: false, null: false, comment: "If True, some students are girls; if _boys and _girls are both False, unknown"
  end

  create_table "customers_tags", primary_key: ["customer_id", "tag_id"], force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.bigint "customer_id", null: false
    t.bigint "tag_id", null: false
    t.index ["tag_id", "customer_id"], name: "index_customers_tags_on_tag_id_and_customer_id"
  end

  create_table "delivery_methods", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.string "abbreviation", null: false
  end

  create_table "districts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "region_id", null: false
    t.string "name", null: false
    t.string "color", null: false
  end

  create_table "issue_notes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "issue_id", null: false
    t.text "note", limit: 16777215, null: false
    t.datetime "created_at", null: false
    t.integer "created_by"
    t.index ["issue_id"], name: "index_issue_notes_on_issue_id"
  end

  create_table "issues", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.integer "publication_id"
    t.date "issue_date"
    t.string "issue_number", default: "", null: false
    t.string "box_sizes", null: false
  end

  create_table "orders", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "customer_id"
    t.integer "issue_id"
    t.integer "standing_order_id"
    t.integer "num_copies"
    t.string "comments"
    t.date "order_date"
    t.string "council"
    t.string "customer_name"
    t.string "delivery_address", default: "", null: false
    t.string "delivery_contact"
    t.string "region", null: false
    t.string "delivery_method", null: false
    t.string "primary_contact_sms_numbers"
    t.string "headmaster_sms_numbers"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["issue_id"], name: "index_orders_on_issue_id"
    t.index ["standing_order_id", "issue_id"], name: "index_orders_on_standing_order_id_and_issue_id_and_deleted_at"
  end

  create_table "publications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.boolean "tracks_standing_orders", default: true, null: false
    t.boolean "pr_material", default: true
  end

  create_table "regions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name"
    t.integer "population"
    t.text "councils_separated_by_newline", limit: 16777215
    t.integer "delivery_method_id", null: false
    t.string "manager", default: "", null: false
    t.integer "n_schools", default: 0
  end

  create_table "standing_orders", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.integer "customer_id"
    t.integer "publication_id"
    t.integer "num_copies"
    t.string "comments"
    t.datetime "created_at"
    t.index ["customer_id", "publication_id"], name: "index_standing_orders_on_customer_id_and_publication_id"
    t.index ["customer_id"], name: "index_standing_orders_on_customer_id"
    t.index ["publication_id"], name: "index_standing_orders_on_publication_id"
  end

  create_table "survey_responses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.datetime "created_at", null: false
    t.integer "customer_id"
    t.integer "survey_id", null: false
    t.string "region_name", default: "", null: false
    t.string "sm_respondent_id", null: false
    t.text "answers_json", null: false
    t.datetime "start_date", null: false
    t.datetime "end_date", null: false
    t.datetime "reviewed_at"
  end

  create_table "surveys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", null: false
    t.text "sm_data_csv", limit: 16777215, null: false
  end

  create_table "tags", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "name", null: false
    t.string "color", null: false
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
    t.string "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "roles"
  end

end

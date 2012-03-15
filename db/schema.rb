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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120307204119) do

  create_table "actions", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "person_id"
    t.datetime "occurred_at"
    t.text     "details"
    t.boolean  "starred"
    t.integer  "dollar_amount"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "subtype"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.integer  "creator_id"
    t.string   "old_mongo_id"
  end

  create_table "addresses", :force => true do |t|
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_mongo_id"
  end

  create_table "admin_stats", :force => true do |t|
    t.integer  "users"
    t.integer  "logged_in_more_than_once"
    t.integer  "organizations"
    t.integer  "fa_connected_orgs"
    t.integer  "active_fafs_projects"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ticketing_kits"
    t.integer  "donation_kits"
    t.integer  "tickets"
    t.integer  "tickets_sold"
    t.integer  "donations"
    t.integer  "fafs_donations"
  end

  create_table "admins", :force => true do |t|
    t.string   "email",                                              :null => false
    t.string   "encrypted_password",   :limit => 128,                :null => false
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",                     :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "reset_password_token"
  end

  add_index "admins", ["email"], :name => "index_admins_on_email", :unique => true
  add_index "admins", ["unlock_token"], :name => "index_admins_on_unlock_token", :unique => true

  create_table "bank_accounts", :force => true do |t|
    t.string   "routing_number"
    t.string   "number"
    t.string   "account_type"
    t.string   "name"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "phone"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "carts", :force => true do |t|
    t.string   "state"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "reseller_id"
  end

  create_table "charts", :force => true do |t|
    t.string  "name"
    t.boolean "is_template"
    t.integer "event_id"
    t.integer "organization_id"
    t.string  "old_mongo_id"
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

  create_table "donations", :force => true do |t|
    t.integer  "amount"
    t.integer  "cart_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "events", :force => true do |t|
    t.string   "name"
    t.string   "producer"
    t.boolean  "is_free"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_mongo_id"
    t.datetime "deleted_at"
    t.string   "contact_phone"
    t.string   "contact_email"
    t.text     "description"
    t.integer  "venue_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.string   "special_instructions_caption", :default => "Special Instructions"
    t.boolean  "show_special_instructions",    :default => false
  end

  create_table "fiscally_sponsored_projects", :force => true do |t|
    t.string   "fs_project_id"
    t.string   "fa_member_id"
    t.string   "name"
    t.string   "category"
    t.text     "profile"
    t.string   "website"
    t.datetime "applied_on"
    t.string   "status"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_errors", :force => true do |t|
    t.integer  "import_id"
    t.text     "row_data"
    t.text     "error_message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "import_rows", :force => true do |t|
    t.integer "import_id"
    t.text    "content"
  end

  create_table "imports", :force => true do |t|
    t.integer  "user_id"
    t.string   "s3_bucket"
    t.string   "s3_key"
    t.string   "s3_etag"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",          :default => "pending"
    t.text     "import_headers"
    t.integer  "organization_id"
  end

  create_table "items", :force => true do |t|
    t.string   "state"
    t.string   "product_type"
    t.integer  "product_id"
    t.integer  "price"
    t.integer  "realized_price"
    t.integer  "net"
    t.string   "settlement_id"
    t.string   "fs_project_id"
    t.integer  "nongift_amount"
    t.boolean  "is_noncash"
    t.boolean  "is_stock"
    t.boolean  "is_anonymous"
    t.datetime "fs_available_on"
    t.datetime "reversed_at"
    t.string   "reversed_note"
    t.integer  "order_id"
    t.integer  "show_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_mongo_id"
    t.boolean  "reseller_settled"
    t.integer  "reseller_net"
    t.integer  "reseller_order_id"
  end

  create_table "kits", :force => true do |t|
    t.string   "state"
    t.string   "type"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", :force => true do |t|
    t.integer "user_id"
    t.integer "organization_id"
  end

  create_table "notes", :force => true do |t|
    t.integer  "person_id"
    t.integer  "user_id"
    t.string   "type"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "occurred_at"
    t.integer  "organization_id"
  end

  create_table "order_view", :id => false, :force => true do |t|
    t.integer  "id",                :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "transaction_id"
    t.integer  "price"
    t.integer  "service_fee"
    t.integer  "fa_id"
    t.integer  "organization_id"
    t.integer  "person_id"
    t.string   "organization_name"
    t.string   "person_first_name"
    t.string   "person_last_name"
  end

  create_table "orders", :force => true do |t|
    t.string   "transaction_id"
    t.integer  "price"
    t.integer  "organization_id"
    t.integer  "person_id"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "service_fee"
    t.integer  "fa_id"
    t.string   "details"
    t.string   "old_mongo_id"
    t.string   "type"
    t.string   "payment_method"
    t.integer  "reseller_order_id"
    t.text     "special_instructions"
  end

  create_table "organizations", :force => true do |t|
    t.string   "name"
    t.string   "time_zone"
    t.string   "legal_organization_name"
    t.string   "ein"
    t.string   "fa_member_id"
    t.string   "website"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer  "organization_id"
    t.string   "state"
    t.string   "type"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "company_name"
    t.string   "website"
    t.boolean  "dummy"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "old_mongo_id"
    t.string   "person_type"
    t.string   "twitter_handle"
    t.string   "facebook_url"
    t.string   "linked_in_url"
    t.integer  "import_id"
  end

  create_table "phones", :force => true do |t|
    t.string   "kind"
    t.string   "number"
    t.integer  "person_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "purchasable_tickets", :force => true do |t|
    t.integer  "cart_id"
    t.string   "ticket_id"
    t.string   "lock_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reseller_attachments", :force => true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "reseller_profile_id"
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "comment"
  end

  create_table "reseller_events", :force => true do |t|
    t.integer  "reseller_profile_id"
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "venue_id"
    t.string   "producer"
    t.string   "url"
  end

  create_table "reseller_items", :force => true do |t|
    t.string   "state"
    t.integer  "product_id"
    t.integer  "price"
    t.integer  "realized_price"
    t.integer  "net"
    t.string   "settlement_id"
    t.integer  "show_id"
    t.integer  "reseller_order_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reseller_orders", :force => true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reseller_profiles", :force => true do |t|
    t.integer  "organization_id"
    t.text     "url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fee",             :default => 100
  end

  create_table "reseller_shows", :force => true do |t|
    t.string   "state"
    t.datetime "datetime"
    t.integer  "reseller_event_id"
    t.integer  "reseller_profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sections", :force => true do |t|
    t.text    "name"
    t.integer "capacity"
    t.integer "price"
    t.integer "chart_id"
    t.string  "old_mongo_id"
  end

  create_table "segments", :force => true do |t|
    t.string  "name"
    t.string  "terms"
    t.integer "organization_id"
  end

  create_table "settlements", :force => true do |t|
    t.string   "transaction_id"
    t.string   "ach_response_code"
    t.string   "fail_message"
    t.datetime "created_at"
    t.boolean  "success"
    t.integer  "gross"
    t.integer  "realized_gross"
    t.integer  "net"
    t.integer  "items_count"
    t.integer  "organization_id"
    t.integer  "show_id"
    t.datetime "updated_at"
    t.string   "old_mongo_id"
  end

  create_table "shows", :force => true do |t|
    t.string   "state"
    t.datetime "datetime"
    t.integer  "event_id"
    t.integer  "chart_id"
    t.integer  "organization_id"
    t.string   "old_mongo_id"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "ticket_offers", :force => true do |t|
    t.integer  "organization_id"
    t.integer  "show_id"
    t.integer  "section_id"
    t.integer  "reseller_profile_id"
    t.string   "status",              :default => "creating", :null => false
    t.integer  "count",               :default => 0,          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "rejection_reason"
  end

  create_table "tickets", :force => true do |t|
    t.string   "venue"
    t.string   "state"
    t.integer  "price"
    t.integer  "sold_price"
    t.datetime "sold_at"
    t.integer  "buyer_id"
    t.integer  "show_id"
    t.integer  "organization_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cart_id"
    t.string   "old_mongo_id"
    t.integer  "section_id"
  end

  add_index "tickets", ["state"], :name => "index_tickets_on_state"

  create_table "users", :force => true do |t|
    t.string   "email",                                              :null => false
    t.string   "encrypted_password",   :limit => 128
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "customer_id"
    t.datetime "suspended_at"
    t.string   "suspension_reason"
    t.string   "invitation_token",     :limit => 60
    t.datetime "invitation_sent_at"
    t.integer  "invited_by_id"
    t.string   "invited_by_type"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["invitation_token"], :name => "index_users_on_invitation_token"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "venues", :force => true do |t|
    t.integer "organization_id"
    t.string  "name"
    t.string  "address1"
    t.string  "address2"
    t.string  "city"
    t.string  "state"
    t.string  "zip"
    t.string  "country"
    t.string  "time_zone"
    t.string  "phone"
    t.float   "lat"
    t.float   "long"
  end

end

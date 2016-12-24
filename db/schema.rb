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

ActiveRecord::Schema.define(version: 20161224163703) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree

  create_table "areas", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "latitude",               precision: 8, scale: 5
    t.decimal  "longitude",              precision: 8, scale: 5
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "icon",         limit: 255
    t.string   "marker_color", limit: 255
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",               default: 0, null: false
    t.integer  "attempts",               default: 0, null: false
    t.text     "handler",                            null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_id"
  end

  add_index "items", ["category_id"], name: "index_items_on_category_id", using: :btree

  create_table "locations", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "address",       limit: 255
    t.string   "postal_code",   limit: 255
    t.string   "province",      limit: 255
    t.string   "city",          limit: 255
    t.string   "phone_number",  limit: 255
    t.string   "website",       limit: 255
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "street_number", limit: 255
    t.decimal  "latitude",                  precision: 7, scale: 5
    t.decimal  "longitude",                 precision: 8, scale: 5
    t.integer  "user_id"
    t.integer  "area_id"
  end

  add_index "locations", ["area_id"], name: "index_locations_on_area_id", using: :btree
  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "map_tiles", force: :cascade do |t|
    t.string   "name"
    t.string   "tile_url"
    t.string   "attribution"
    t.string   "api_key"
    t.string   "map_name"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "post_items", force: :cascade do |t|
    t.integer  "post_id"
    t.integer  "item_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "post_items", ["item_id"], name: "index_post_items_on_item_id", using: :btree
  add_index "post_items", ["post_id"], name: "index_post_items_on_post_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.text     "description"
    t.integer  "location_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "username_used"
    t.boolean  "giving"
    t.date     "expire_date"
    t.string   "image",         limit: 255
    t.string   "anon_name",     limit: 255
    t.string   "anon_email",    limit: 255
    t.jsonb    "marker_info",               default: {}
  end

  add_index "posts", ["location_id"], name: "index_posts_on_location_id", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string   "key",        limit: 255
    t.string   "value",      limit: 1000
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "simple_captcha_data", force: :cascade do |t|
    t.string   "key",        limit: 40
    t.string   "value",      limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "simple_captcha_data", ["key"], name: "idx_key", using: :btree

  create_table "todos", force: :cascade do |t|
    t.string   "description"
    t.string   "condition"
    t.string   "alert"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,             null: false
    t.string   "encrypted_password",     limit: 255,             null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "role"
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "username",               limit: 255
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end

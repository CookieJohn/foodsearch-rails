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

ActiveRecord::Schema.define(version: 20170802072302) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "categories", force: :cascade do |t|
    t.bigint "facebook_id"
    t.string "facebook_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facebook_id"], name: "index_categories_on_facebook_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "line_user_id"
    t.integer "max_distance"
    t.float "min_score"
    t.boolean "random_type", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "get_google_result", default: false
    t.string "facebook_user_id"
    t.json "last_search", default: {}
    t.index ["line_user_id"], name: "index_users_on_line_user_id"
  end

end

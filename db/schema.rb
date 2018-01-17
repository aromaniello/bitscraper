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

ActiveRecord::Schema.define(version: 20180117025655) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bitcointalk_users", force: :cascade do |t|
    t.string "username"
    t.string "twitter_user_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "twitter_reports", force: :cascade do |t|
    t.bigint "bitcointalk_user_id"
    t.datetime "post_date"
    t.integer "week"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "page_number"
    t.index ["bitcointalk_user_id"], name: "index_twitter_reports_on_bitcointalk_user_id"
  end

  create_table "twitter_statuses", force: :cascade do |t|
    t.bigint "twitter_report_id"
    t.integer "status_index"
    t.string "twitter_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["twitter_report_id"], name: "index_twitter_statuses_on_twitter_report_id"
  end

end

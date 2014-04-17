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

ActiveRecord::Schema.define(version: 20140417010354) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "projects", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "urls_count",    default: 0
    t.integer  "last_sweep_id"
  end

  create_table "snapshot_diff_clusters", force: true do |t|
    t.integer  "snapshot_diff_id"
    t.integer  "start"
    t.integer  "finish"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "snapshot_diffs", force: true do |t|
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.decimal  "diff_in_percent"
    t.integer  "before_snapshot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "image_height"
    t.integer  "image_width"
  end

  create_table "snapshots", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "url_id"
    t.datetime "accepted_at"
    t.datetime "rejected_at"
    t.string   "title"
    t.integer  "viewport_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "sweep_id"
    t.integer  "snapshot_diff_id"
    t.integer  "compared_with_id"
    t.text     "log"
  end

  add_index "snapshots", ["sweep_id"], name: "index_snapshots_on_sweep_id", using: :btree

  create_table "sweeps", force: true do |t|
    t.integer  "project_id"
    t.string   "title",                          null: false
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count_pending",      default: 0
    t.integer  "count_accepted",     default: 0
    t.integer  "count_rejected",     default: 0
    t.integer  "count_under_review", default: 0
    t.datetime "start_time"
    t.string   "email"
    t.datetime "emailed_at"
  end

  create_table "urls", force: true do |t|
    t.text     "address"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
    t.integer  "snapshots_count", default: 0
  end

  create_table "viewports", force: true do |t|
    t.integer  "project_id"
    t.integer  "width",      limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "user_agent"
  end

end

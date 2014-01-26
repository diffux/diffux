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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140126185147) do

  create_table "baselines", :force => true do |t|
    t.integer  "url_id"
    t.integer  "snapshot_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "snapshots", :force => true do |t|
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.integer  "url_id"
    t.string   "external_image_id"
    t.string   "diff_external_image_id"
    t.decimal  "diff_from_previous"
    t.integer  "diffed_with_snapshot_id"
  end

  create_table "urls", :force => true do |t|
    t.string   "address"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "viewport_width", :default => 320
    t.string   "name"
    t.boolean  "active",         :default => true
  end

end

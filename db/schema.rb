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

ActiveRecord::Schema.define(:version => 20130923145231) do

  create_table "activities", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start"
    t.time     "length"
    t.datetime "end_date"
    t.integer  "user_id"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "street"
    t.string   "city"
    t.string   "zip_code"
    t.string   "country"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  create_table "activities_users", :id => false, :force => true do |t|
    t.integer "activity_id"
    t.integer "user_id"
  end

  create_table "activity_notifications", :force => true do |t|
    t.integer  "device_id",                        :null => false
    t.integer  "errors_nb",         :default => 0
    t.datetime "sent_at"
    t.string   "notification_type"
    t.integer  "activity_id",                      :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "activity_notifications", ["activity_id"], :name => "index_activity_notifications_on_activity_id"
  add_index "activity_notifications", ["device_id"], :name => "index_activity_notifications_on_device_id"

  create_table "api_keys", :force => true do |t|
    t.string   "access_token"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "devices", :force => true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "badge"
  end

  create_table "users", :force => true do |t|
    t.string   "token"
    t.string   "salt"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "user_name"
    t.string   "password"
    t.string   "email"
    t.boolean  "active"
    t.string   "profile_image_file_name"
    t.string   "profile_image_content_type"
    t.integer  "profile_image_file_size"
    t.datetime "profile_image_updated_at"
  end

end

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

ActiveRecord::Schema.define(version: 2019_02_26_132052) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cities", force: :cascade do |t|
    t.string "name"
    t.string "region"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "drivers", force: :cascade do |t|
    t.string "name"
    t.string "phone"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id"
    t.index ["vehicle_id"], name: "index_drivers_on_vehicle_id"
  end

  create_table "route_cities", force: :cascade do |t|
    t.bigint "route_id"
    t.bigint "city_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_route_cities_on_city_id"
    t.index ["route_id"], name: "index_route_cities_on_route_id"
  end

  create_table "routes", force: :cascade do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.string "load_type"
    t.float "load_sum"
    t.integer "stops_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vehicle_id"
    t.bigint "driver_id"
    t.index ["driver_id"], name: "index_routes_on_driver_id"
    t.index ["vehicle_id"], name: "index_routes_on_vehicle_id"
  end

  create_table "vehicles", force: :cascade do |t|
    t.float "capacity"
    t.string "load_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "driver_id"
    t.index ["driver_id"], name: "index_vehicles_on_driver_id"
  end

  add_foreign_key "drivers", "vehicles"
  add_foreign_key "route_cities", "cities"
  add_foreign_key "route_cities", "routes"
  add_foreign_key "routes", "drivers"
  add_foreign_key "routes", "vehicles"
  add_foreign_key "vehicles", "drivers"
end

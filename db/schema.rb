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

ActiveRecord::Schema.define(version: 20160508162757) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "currencies", force: :cascade do |t|
    t.string   "iso",        limit: 3, null: false
    t.string   "name",                 null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.index ["iso"], name: "index_currencies_on_iso", using: :btree
    t.index ["name"], name: "index_currencies_on_name", using: :btree
  end

  create_table "exchange_rates", force: :cascade do |t|
    t.integer  "currency_id"
    t.string   "exchange_string", null: false
    t.date     "date",            null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.index ["currency_id"], name: "index_exchange_rates_on_currency_id", using: :btree
    t.index ["date"], name: "index_exchange_rates_on_date", using: :btree
  end

  create_table "notes", force: :cascade do |t|
    t.string   "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

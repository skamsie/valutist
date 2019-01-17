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

ActiveRecord::Schema.define(version: 2019_01_17_143204) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "exchange_rates", force: :cascade do |t|
    t.datetime "created_at"
    t.string "base_currency"
    t.float "BGN"
    t.float "BRL"
    t.float "BWP"
    t.float "CAD"
    t.float "CHF"
    t.float "DKK"
    t.float "EUR"
    t.float "GBP"
    t.float "HUF"
    t.float "INR"
    t.float "ISK"
    t.float "JPY"
    t.float "MXN"
    t.float "NOK"
    t.float "RUB"
    t.float "SAR"
    t.float "SEK"
    t.float "USD"
  end

end

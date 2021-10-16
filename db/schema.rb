# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_13_011720) do

  create_table "portfolios", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "stock_portfolio_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "stock_id", null: false
    t.integer "portfolio_id", null: false
    t.decimal "stock_value", precision: 10, scale: 6
    t.decimal "stock_quantity", precision: 10, scale: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["portfolio_id"], name: "index_stock_portfolio_users_on_portfolio_id"
    t.index ["stock_id"], name: "index_stock_portfolio_users_on_stock_id"
    t.index ["user_id", "stock_id", "portfolio_id"], name: "uniq_index_on_user_and_stock_and_portfolio"
    t.index ["user_id"], name: "index_stock_portfolio_users_on_user_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.string "symbol"
    t.text "stock_info", limit: 4294967295
    t.date "last_call_to_api"
    t.string "company_name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "sector"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.text "stock_list", limit: 4294967295
    t.integer "last_stock_updated", default: 0
    t.string "fullname"
    t.text "last_query", limit: 4294967295
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "stock_portfolio_users", "portfolios"
  add_foreign_key "stock_portfolio_users", "stocks"
  add_foreign_key "stock_portfolio_users", "users"
end

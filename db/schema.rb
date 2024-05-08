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

ActiveRecord::Schema[7.1].define(version: 2024_05_08_132259) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "customer_infos", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "name"
    t.string "email"
    t.string "gender"
    t.integer "age"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_customer_infos_on_order_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title"
    t.decimal "price", precision: 10, scale: 2
    t.datetime "starts_on"
    t.datetime "ends_on"
    t.string "location"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "capacity"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "quantity"
    t.bigint "event_id", null: false
    t.decimal "ticket_price", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reference"
    t.index ["event_id"], name: "index_orders_on_event_id"
    t.index ["reference"], name: "index_orders_on_reference", unique: true
  end

  create_table "ticket_reservations", force: :cascade do |t|
    t.bigint "ticket_sale_id", null: false
    t.string "reference"
    t.integer "quantity"
    t.string "status"
    t.datetime "valid_until"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reference"], name: "index_ticket_reservations_on_reference", unique: true
    t.index ["ticket_sale_id"], name: "index_ticket_reservations_on_ticket_sale_id"
  end

  create_table "ticket_sales", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.integer "number_of_sold_tickets", default: 0
    t.integer "number_of_reserved_tickets", default: 0
    t.integer "capacity", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_ticket_sales_on_event_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "customer_infos", "orders"
  add_foreign_key "orders", "events"
  add_foreign_key "ticket_reservations", "ticket_sales"
  add_foreign_key "ticket_sales", "events"
end

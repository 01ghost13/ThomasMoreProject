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

ActiveRecord::Schema.define(version: 2020_05_05_075637) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "administrators", id: :serial, force: :cascade do |t|
    t.boolean "is_super"
    t.string "organisation"
    t.integer "info_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organisation_address"
    t.index ["info_id"], name: "index_administrators_on_info_id"
    t.index ["organisation_address"], name: "index_administrators_on_organisation_address", unique: true
  end

  create_table "clients", id: :serial, force: :cascade do |t|
    t.string "code_name"
    t.date "birth_date"
    t.date "date_off"
    t.integer "gender"
    t.string "address"
    t.boolean "is_active"
    t.string "password_digest"
    t.boolean "is_current_in_school"
    t.integer "mentor_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "emotion_recognition", default: false
    t.boolean "gaze_trace", default: false
    t.bigint "employee_id"
    t.index ["employee_id"], name: "index_clients_on_employee_id"
    t.index ["mentor_id"], name: "index_clients_on_mentor_id"
  end

  create_table "emotion_state_results", force: :cascade do |t|
    t.json "states", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "organisation"
    t.string "phone"
    t.string "organisation_address"
    t.string "last_name"
    t.string "name"
    t.bigint "employee_id"
    t.index ["employee_id"], name: "index_employees_on_employee_id"
  end

  create_table "gaze_trace_results", force: :cascade do |t|
    t.json "gaze_points", default: {}
    t.integer "screen_width"
    t.integer "screen_height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "picture_bounds", default: {}
  end

  create_table "infos", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "last_name"
    t.string "mail"
    t.string "password_digest"
    t.string "phone"
    t.boolean "is_mail_confirmed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirm_token"
    t.string "reset_token"
  end

  create_table "interests", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "languages", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "mentors", id: :serial, force: :cascade do |t|
    t.integer "info_id"
    t.integer "administrator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrator_id"], name: "index_mentors_on_administrator_id"
    t.index ["info_id"], name: "index_mentors_on_info_id"
  end

  create_table "picture_interests", id: :serial, force: :cascade do |t|
    t.integer "earned_points"
    t.integer "picture_id"
    t.integer "interest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "youtube_link_id"
    t.index ["interest_id", "picture_id"], name: "index_picture_interests_on_interest_id_and_picture_id", unique: true
    t.index ["interest_id"], name: "index_picture_interests_on_interest_id"
    t.index ["picture_id"], name: "index_picture_interests_on_picture_id"
    t.index ["youtube_link_id"], name: "index_picture_interests_on_youtube_link_id"
  end

  create_table "pictures", id: :serial, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "question_results", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.datetime "start"
    t.datetime "end"
    t.boolean "was_rewrited"
    t.integer "result_of_test_id"
    t.integer "was_checked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "question_id"
    t.bigint "gaze_trace_result_id"
    t.bigint "emotion_state_result_id"
    t.index ["emotion_state_result_id"], name: "index_question_results_on_emotion_state_result_id"
    t.index ["gaze_trace_result_id"], name: "index_question_results_on_gaze_trace_result_id"
    t.index ["question_id"], name: "index_question_results_on_question_id"
    t.index ["result_of_test_id"], name: "index_question_results_on_result_of_test_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.integer "picture_id"
    t.integer "test_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "youtube_link_id"
    t.index ["picture_id"], name: "index_questions_on_picture_id"
    t.index ["test_id"], name: "index_questions_on_test_id"
    t.index ["youtube_link_id"], name: "index_questions_on_youtube_link_id"
  end

  create_table "result_of_tests", id: :serial, force: :cascade do |t|
    t.boolean "was_in_school"
    t.boolean "is_ended"
    t.integer "test_id"
    t.integer "client_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_outdated", default: false
    t.boolean "emotion_recognition", default: false
    t.boolean "gaze_trace", default: false
  end

  create_table "test_availabilities", force: :cascade do |t|
    t.bigint "test_id"
    t.bigint "user_id"
    t.boolean "available", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_id", "user_id"], name: "unique_test_roles", unique: true
    t.index ["test_id"], name: "index_test_availabilities_on_test_id"
    t.index ["user_id"], name: "index_test_availabilities_on_user_id"
  end

  create_table "tests", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "translated_columns", force: :cascade do |t|
    t.string "target_column", null: false
    t.string "translation", null: false
    t.string "translatable_type"
    t.bigint "translatable_id"
    t.bigint "language_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["language_id"], name: "index_translated_columns_on_language_id"
    t.index ["translatable_type", "translatable_id"], name: "translatable_index"
  end

  create_table "translations", force: :cascade do |t|
    t.string "field", null: false
    t.string "value", null: false
    t.bigint "language_id", null: false
    t.index ["field", "language_id"], name: "index_translations_on_field_and_language_id", unique: true
    t.index ["language_id"], name: "index_translations_on_language_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "role", null: false
    t.string "userable_type", null: false
    t.bigint "userable_id", null: false
    t.boolean "is_active", default: true, null: false
    t.date "date_off"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.bigint "language_id", default: 1, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["language_id"], name: "index_users_on_language_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["userable_type", "userable_id"], name: "index_users_on_userable_type_and_userable_id"
  end

  create_table "youtube_links", force: :cascade do |t|
    t.string "description"
    t.string "link"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "administrators", "infos"
  add_foreign_key "clients", "mentors"
  add_foreign_key "mentors", "administrators"
  add_foreign_key "mentors", "infos"
  add_foreign_key "picture_interests", "interests"
  add_foreign_key "picture_interests", "pictures"
  add_foreign_key "question_results", "questions"
  add_foreign_key "question_results", "result_of_tests"
  add_foreign_key "questions", "pictures"
  add_foreign_key "questions", "tests"
  add_foreign_key "test_availabilities", "tests"
  add_foreign_key "test_availabilities", "users"
end

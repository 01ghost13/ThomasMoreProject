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

ActiveRecord::Schema.define(version: 2018_10_21_145118) do

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

  create_table "modes", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "picture_interests", id: :serial, force: :cascade do |t|
    t.integer "earned_points"
    t.integer "picture_id"
    t.integer "interest_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["interest_id", "picture_id"], name: "index_picture_interests_on_interest_id_and_picture_id", unique: true
    t.index ["interest_id"], name: "index_picture_interests_on_interest_id"
    t.index ["picture_id"], name: "index_picture_interests_on_picture_id"
  end

  create_table "pictures", id: :serial, force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "image_file_name"
    t.string "image_content_type"
    t.integer "image_file_size"
    t.datetime "image_updated_at"
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
    t.index ["question_id"], name: "index_question_results_on_question_id"
    t.index ["result_of_test_id"], name: "index_question_results_on_result_of_test_id"
  end

  create_table "questions", id: :serial, force: :cascade do |t|
    t.integer "number"
    t.boolean "is_tutorial"
    t.integer "picture_id"
    t.integer "test_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["picture_id"], name: "index_questions_on_picture_id"
    t.index ["test_id"], name: "index_questions_on_test_id"
  end

  create_table "result_of_tests", id: :serial, force: :cascade do |t|
    t.boolean "was_in_school"
    t.boolean "is_ended"
    t.integer "test_id"
    t.integer "schooling_id"
    t.integer "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_outdated", default: false
  end

  create_table "schoolings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", id: :serial, force: :cascade do |t|
    t.string "code_name"
    t.date "birth_date"
    t.date "date_off"
    t.integer "gender"
    t.string "adress"
    t.boolean "is_active"
    t.string "password_digest"
    t.boolean "is_current_in_school"
    t.integer "schooling_id"
    t.integer "tutor_id"
    t.integer "mode_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["mode_id"], name: "index_students_on_mode_id"
    t.index ["schooling_id"], name: "index_students_on_schooling_id"
    t.index ["tutor_id"], name: "index_students_on_tutor_id"
  end

  create_table "tests", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tutors", id: :serial, force: :cascade do |t|
    t.integer "info_id"
    t.integer "administrator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["administrator_id"], name: "index_tutors_on_administrator_id"
    t.index ["info_id"], name: "index_tutors_on_info_id"
  end

  add_foreign_key "administrators", "infos"
  add_foreign_key "picture_interests", "interests"
  add_foreign_key "picture_interests", "pictures"
  add_foreign_key "question_results", "questions"
  add_foreign_key "question_results", "result_of_tests"
  add_foreign_key "questions", "pictures"
  add_foreign_key "questions", "tests"
  add_foreign_key "students", "modes"
  add_foreign_key "students", "schoolings"
  add_foreign_key "students", "tutors"
  add_foreign_key "tutors", "administrators"
  add_foreign_key "tutors", "infos"
end

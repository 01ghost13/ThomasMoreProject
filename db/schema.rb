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

ActiveRecord::Schema.define(version: 20160303221831) do

  create_table "administrators", force: :cascade do |t|
    t.boolean  "is_super"
    t.string   "organisation"
    t.integer  "info_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "administrators", ["info_id"], name: "index_administrators_on_info_id"

  create_table "infos", force: :cascade do |t|
    t.string   "name"
    t.string   "last_name"
    t.string   "mail"
    t.string   "password_digest"
    t.string   "phone"
    t.boolean  "is_mail_confirmed"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "interests", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "modes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "picture_interests", force: :cascade do |t|
    t.integer  "earned_points"
    t.integer  "picture_id"
    t.integer  "interest_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "picture_interests", ["interest_id"], name: "index_picture_interests_on_interest_id"
  add_index "picture_interests", ["picture_id"], name: "index_picture_interests_on_picture_id"

  create_table "pictures", force: :cascade do |t|
    t.string   "path"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "points", force: :cascade do |t|
    t.integer  "earned_points"
    t.integer  "interest_id"
    t.integer  "result_of_test_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "points", ["interest_id"], name: "index_points_on_interest_id"
  add_index "points", ["result_of_test_id"], name: "index_points_on_result_of_test_id"

  create_table "question_results", force: :cascade do |t|
    t.integer  "number"
    t.datetime "start"
    t.datetime "end"
    t.boolean  "was_rewrited"
    t.integer  "result_of_test_id"
    t.integer  "was_checked"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "question_results", ["result_of_test_id"], name: "index_question_results_on_result_of_test_id"

  create_table "questions", force: :cascade do |t|
    t.integer  "number"
    t.boolean  "is_tutorial"
    t.integer  "picture_id"
    t.integer  "test_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "questions", ["picture_id"], name: "index_questions_on_picture_id"
  add_index "questions", ["test_id"], name: "index_questions_on_test_id"

  create_table "result_of_tests", force: :cascade do |t|
    t.boolean  "was_in_school"
    t.boolean  "is_ended"
    t.integer  "test_id"
    t.integer  "schooling_id"
    t.integer  "student_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "schoolings", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "students", force: :cascade do |t|
    t.string   "code_name"
    t.date     "birth_date"
    t.date     "date_off"
    t.integer  "gender"
    t.string   "adress"
    t.boolean  "is_active"
    t.string   "password_digest"
    t.boolean  "is_current_in_school"
    t.integer  "schooling_id"
    t.integer  "tutor_id"
    t.integer  "mode_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "students", ["mode_id"], name: "index_students_on_mode_id"
  add_index "students", ["schooling_id"], name: "index_students_on_schooling_id"
  add_index "students", ["tutor_id"], name: "index_students_on_tutor_id"

  create_table "tests", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.string   "version"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "tutors", force: :cascade do |t|
    t.integer  "info_id"
    t.integer  "administrator_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "tutors", ["administrator_id"], name: "index_tutors_on_administrator_id"
  add_index "tutors", ["info_id"], name: "index_tutors_on_info_id"

end

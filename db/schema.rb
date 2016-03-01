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

ActiveRecord::Schema.define(version: 20160301092924) do

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
    t.string   "password"
    t.string   "phone"
    t.boolean  "confirmation"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "interests", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "interests_pictures", id: false, force: :cascade do |t|
    t.integer "interests_id"
    t.integer "pictures_id"
  end

  add_index "interests_pictures", ["interests_id"], name: "index_interests_pictures_on_interests_id"
  add_index "interests_pictures", ["pictures_id"], name: "index_interests_pictures_on_pictures_id"

  create_table "last_results", force: :cascade do |t|
    t.integer  "time"
    t.date     "date"
    t.boolean  "is_finished"
    t.integer  "current_question"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "last_results_points", force: :cascade do |t|
    t.integer "last_results_id"
    t.integer "point_id"
  end

  add_index "last_results_points", ["last_results_id"], name: "index_last_results_points_on_last_results_id"
  add_index "last_results_points", ["point_id"], name: "index_last_results_points_on_point_id"

  create_table "modes", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pictures", force: :cascade do |t|
    t.string   "path"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "pictures_questions", id: false, force: :cascade do |t|
    t.integer "pictures_id"
    t.integer "questions_id"
  end

  add_index "pictures_questions", ["pictures_id"], name: "index_pictures_questions_on_pictures_id"
  add_index "pictures_questions", ["questions_id"], name: "index_pictures_questions_on_questions_id"

  create_table "point_last_results", force: :cascade do |t|
    t.integer  "earned_points"
    t.integer  "interest_id"
    t.integer  "last_result_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "point_last_results", ["interest_id"], name: "index_point_last_results_on_interest_id"
  add_index "point_last_results", ["last_result_id"], name: "index_point_last_results_on_last_result_id"

  create_table "points", force: :cascade do |t|
    t.integer  "earned_points"
    t.integer  "interest_id"
    t.integer  "stats_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "points", ["interest_id"], name: "index_points_on_interest_id"
  add_index "points", ["stats_id"], name: "index_points_on_stats_id"

  create_table "questions", force: :cascade do |t|
    t.integer  "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stats", force: :cascade do |t|
    t.integer  "count_successed_tests"
    t.integer  "max_time"
    t.integer  "min_time"
    t.integer  "avg_time"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "stats_points", id: false, force: :cascade do |t|
    t.integer "stat_id"
    t.integer "point_id"
  end

  add_index "stats_points", ["point_id"], name: "index_stats_points_on_point_id"
  add_index "stats_points", ["stat_id"], name: "index_stats_points_on_stat_id"

  create_table "students", force: :cascade do |t|
    t.string   "name"
    t.string   "last_name"
    t.date     "birth_date"
    t.string   "phone"
    t.date     "date_off"
    t.boolean  "gender"
    t.string   "adress"
    t.boolean  "is_active"
    t.integer  "tutor_id"
    t.integer  "stat_id_id"
    t.integer  "mode_id"
    t.integer  "last_result_id"
    t.integer  "test_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "students", ["last_result_id"], name: "index_students_on_last_result_id"
  add_index "students", ["mode_id"], name: "index_students_on_mode_id"
  add_index "students", ["stat_id_id"], name: "index_students_on_stat_id_id"
  add_index "students", ["test_id"], name: "index_students_on_test_id"
  add_index "students", ["tutor_id"], name: "index_students_on_tutor_id"

  create_table "tests", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
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

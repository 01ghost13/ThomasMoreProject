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

ActiveRecord::Schema.define(version: 20160228221532) do

  create_table "administrators", force: :cascade do |t|
    t.boolean  "is_super"
    t.string   "organisation"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

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

  create_table "points", force: :cascade do |t|
    t.integer  "earned_points"
    t.integer  "interest_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

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

  create_table "students", force: :cascade do |t|
    t.string   "name"
    t.string   "last_name"
    t.date     "birth_date"
    t.string   "phone"
    t.date     "date_off"
    t.boolean  "gender"
    t.string   "adress"
    t.boolean  "is_active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tests", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "tutors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end

# == Schema Information
#
# Table name: students
#
#  id                   :integer          not null, primary key
#  code_name            :string
#  birth_date           :date
#  date_off             :date
#  gender               :integer
#  adress               :string
#  is_active            :boolean
#  password_digest      :string
#  is_current_in_school :boolean
#  schooling_id         :integer
#  tutor_id             :integer
#  mode_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  emotion_recognition  :boolean          default(FALSE)
#  gaze_trace           :boolean          default(FALSE)
#

class Student < ActiveRecord::Base
  before_validation :setup_fields, on: :create

  has_secure_password
  has_many :result_of_tests, dependent: :destroy
  belongs_to :tutor, inverse_of: :students
  belongs_to :schooling, inverse_of: :students

  validates :code_name, presence: true, uniqueness: true, length: { in: 6..20}
  validates :gender, presence: true, inclusion: { in: [1,2,3] }
  #1 – dunno
  #2 – Men
  #3 – Women
  validates :tutor,:schooling,:mode_id, presence: true
  validates :is_active, :is_current_in_school, exclusion: { in: [nil] }
  validates :password, presence: true, allow_nil: true, length: {minimum: 4}

  scope :all_students, ->() {all}

  #Setups default fields
  def setup_fields
    self.is_active = true
    self.mode_id = Mode.all.first.id
  end
  
  #Creates map with info
  def show_info
    user_info = {Codename: self.code_name}
    #Adding gender
    if self.gender == 1
      #dunno
      user_info[:Gender] = 'Unknown'
    elsif self.gender == 2
      #men
      user_info[:Gender] = 'Men'
    else
      #women
      user_info[:Gender] = 'Women'
    end
    tutor = Tutor.find(self.tutor_id)
    user_info[:Tutor] = tutor.info.last_name+' '+tutor.info.name
    schooling = Schooling.find(self.schooling_id)
    user_info[:Schooling] = schooling.name
    user_info[:Current_in_school] = self.is_current_in_school ? 'Yes' : 'No'
    user_info
  end

  def show_short
    user_info = {code_name: self.code_name}
    tutor = Tutor.find(self.tutor_id)
    user_info[:tutor] = tutor.show_short
    user_info[:id] = self.id
    user_info[:is_active] = self.is_active
    user_info
  end

  #Hides student for all users except SA
  def hide
    if self.is_active
      self.date_off = Date.current
    else
      self.date_off = nil
    end
    self.is_active = !self.is_active
    self.save
  end

  def get_student_interests(test_id = nil)
    table = execute_sql_statement(
        "SELECT interests.name, was_checked, earned_points, q_res.start as \"start\",
                q_res.end as \"end\", q.number
        FROM question_results as q_res, questions as q, result_of_tests as res, picture_interests as p_i
        LEFT JOIN interests on interests.id = p_i.interest_id
        WHERE p_i.picture_id = q.picture_id AND
              q_res.question_id = q.id AND
              res.id = q_res.result_of_test_id AND
              res.student_id = #{self.id}#{test_id.nil? ? '':'AND'+test_id.to_s};").to_a
    points_interests = Hash.new
    avg_answer_time = Hash.new
    table.each do |i|
      interest = i['name']
      points_interests[interest] = avg_answer_time[interest] = 0 if points_interests[interest].nil?
      points_interests[interest] += i['earned_points'] if i['was_checked'] == 3
      avg_answer_time[interest] += i['end'].to_datetime.to_f - i['start'].to_datetime.to_f
    end
    avg_answer_time.each_key do |key|
      avg_answer_time[key] = avg_answer_time[key] / avg_answer_time.count
    end
    {points_interests: points_interests, avg_answer_time: avg_answer_time}
  end

  def execute_sql_statement(sql)
    results = ActiveRecord::Base.connection.exec_query(sql)
    if results.present?
      results
    else
      nil
    end
  end

  def self.students_of_admin(admin_id)
    all_students.where('admin_id = ?', admin_id)
  end

  def self.students_of_tutor(tutor_id)
    all_students.where('tutor_id = ?', tutor_id)
  end

  def self.all_students
    select(
        'students.id as id, students.code_name as code_name, t.tutor_name as tutor_name,
        t.tutor_last_name as tutor_last_name, a.admin_name as admin_name, a.admin_last_name as admin_last_name,
        a.organisation as organisation, t.admin_id as administrator_id, tutor_id, is_active'
    ).joins(
        "JOIN (#{Tutor.select(
            'infos.name as tutor_name, infos.last_name as tutor_last_name,
            tutors.id as id, tutors.administrator_id as admin_id'
        ).joins('JOIN infos on info_id = infos.id').to_sql}) as t on tutor_id = t.id"
    ).joins(
        "JOIN (#{Administrator.select(
            'infos.name as admin_name, infos.last_name as admin_last_name,
            administrators.id as a_id, administrators.organisation'
        ).joins('JOIN infos on info_id = infos.id').to_sql}) as a on t.admin_id = a.a_id"
    )
  end

  private :setup_fields
end

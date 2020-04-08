# == Schema Information
#
# Table name: clients
#
#  id                   :integer          not null, primary key
#  address              :string
#  birth_date           :date
#  code_name            :string
#  date_off             :date
#  emotion_recognition  :boolean          default(FALSE)
#  gaze_trace           :boolean          default(FALSE)
#  gender               :integer
#  is_active            :boolean
#  is_current_in_school :boolean
#  password_digest      :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  mentor_id            :integer
#

class Client < ActiveRecord::Base
  before_validation :setup_fields, on: :create

  has_secure_password
  has_one :user, as: :userable
  has_many :result_of_tests, dependent: :destroy
  belongs_to :mentor, inverse_of: :clients

  validates :code_name, presence: true, uniqueness: true, length: { in: 6..20}
  validates :gender, presence: true, inclusion: { in: [1,2,3] }
  #1 – dunno
  #2 – Man
  #3 – Woman
  validates :mentor, presence: true
  validates :is_active, :is_current_in_school, exclusion: { in: [nil] }
  validates :password, presence: true, allow_nil: true, length: {minimum: 4}

  scope :all_clients, ->() {all}

  #Setups default fields
  def setup_fields
    self.is_active = true
  end

  def username
    "#{code_name} | Client"
  end

  def email
    'Does not have any'
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
      user_info[:Gender] = 'Man'
    else
      #women
      user_info[:Gender] = 'Woman'
    end
    mentor = Mentor.find(self.mentor_id)
    user_info[:Mentor] = mentor.info.last_name+' '+mentor.info.name
    user_info[:Current_in_school] = self.is_current_in_school ? 'Yes' : 'No'
    user_info
  end

  def show_short
    user_info = {code_name: self.code_name}
    mentor = Mentor.find(self.mentor_id)
    user_info[:mentor] = mentor.show_short
    user_info[:id] = self.id
    user_info[:is_active] = self.is_active
    user_info
  end

  #Hides client for all users except SA
  def hide
    if self.is_active
      self.date_off = Date.current
    else
      self.date_off = nil
    end
    self.is_active = !self.is_active
    self.save
  end

  def get_client_interests(test_id = nil)
    table = execute_sql_statement(
        "SELECT interests.name, was_checked, earned_points, q_res.start as \"start\",
                q_res.end as \"end\", q.number
        FROM question_results as q_res, questions as q, result_of_tests as res, picture_interests as p_i
        LEFT JOIN interests on interests.id = p_i.interest_id
        WHERE p_i.picture_id = q.picture_id AND
              q_res.question_id = q.id AND
              res.id = q_res.result_of_test_id AND
              res.client_id = #{self.id}#{test_id.nil? ? '':'AND'+test_id.to_s};").to_a
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

  def self.clients_of_admin(admin_id)
    all_clients.where('admin_id = ?', admin_id)
  end

  def self.clients_of_mentor(mentor_id)
    all_clients.where('mentor_id = ?', mentor_id)
  end

  def self.all_clients
    select(
        'clients.id as id, clients.code_name as code_name, t.mentor_name as mentor_name,
        t.mentor_last_name as mentor_last_name, a.admin_name as admin_name, a.admin_last_name as admin_last_name,
        a.organisation as organisation, t.admin_id as administrator_id, mentor_id, is_active'
    ).joins(
        "JOIN (#{Mentor.select(
            'infos.name as mentor_name, infos.last_name as mentor_last_name,
            mentors.id as id, mentors.administrator_id as admin_id'
        ).joins('JOIN infos on info_id = infos.id').to_sql}) as t on mentor_id = t.id"
    ).joins(
        "JOIN (#{Administrator.select(
            'infos.name as admin_name, infos.last_name as admin_last_name,
            administrators.id as a_id, administrators.organisation'
        ).joins('JOIN infos on info_id = infos.id').to_sql}) as a on t.admin_id = a.a_id"
    )
  end

  private :setup_fields
end

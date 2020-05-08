class UsersTreeLoader
  attr_reader :user_root

  def initialize(user_root, test_id)
    @user_root = user_root
    @test_id = test_id
  end

  def call
    if user_root.mentor?
      employee = @user_root.employee
      clients = Client
        .where(employee_id: employee.id)
        .includes(:result_of_tests, :user)

      load_results(clients)
    elsif user_root.role == 'local_admin'
      employee = @user_root.employee
      mentors = Employee
        .where(employee_id: employee.id)
        .includes(clients: %i[result_of_tests user])

      load_mentors(mentors)

    elsif user_root.role == 'super_admin'
      local_admins = User
        .all_local_admins
        .joins(:employee)
        .includes(employee: { employees: { clients: %i[result_of_tests user], user: {} }, user: {} })

      load_local_admins(local_admins)
    end
  end

  private

    def load_local_admins(local_admins)
      local_admins.reduce({}) do |memo, local_admin|
        emp = local_admin.employee
        emps = emp.employees
        next memo if emps.blank?
        emps = load_mentors(emps)
        next memo if emps.blank?

        memo[emp] = emps
        memo
      end
    end

    def load_mentors(mentors)
      mentors.reduce({}) do |memo, mentor|
        clients = mentor.clients
        next memo if clients.blank?
        clients = load_results(clients)
        next memo if clients.blank?

        memo[mentor] = clients

        memo
      end
    end

    def load_results(clients)
      clients.reduce({}) do |memo, client|
        results = filter_results(client.result_of_tests, test_id: @test_id)
        next memo if results.blank?

        memo[client] = results
        memo
      end
    end

    def filter_results(results, test_id:)
      results.select { |result| result.test_id == test_id && result.is_ended }
    end
end

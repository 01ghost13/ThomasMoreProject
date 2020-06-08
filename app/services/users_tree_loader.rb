class UsersTreeLoader
  attr_reader :user_root, :tree, :results, :query

  def initialize(user_root, test_id)
    @user_root = user_root
    @test_id = test_id
    @results = []
    @query = Employee.none
  end

  def call(params: nil)
    @tree ||=
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

        local_admins = local_admins.ransack(params)
        @query = local_admins

        load_local_admins(local_admins.result)
      elsif user_root.client?
        clients = Client
          .where(id: user_root.userable_id)
          .includes(:result_of_tests, :user)
        load_results(clients)
      end
  end

  def load_results_for(target)
    return [] if @tree.blank?

    check_subtree(@tree, [], target)
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
        @results += results

        memo[client] = results
        memo
      end
    end

    def filter_results(results, test_id:)
      return results if test_id.blank?
      results.select { |result| result.test_id == test_id && result.is_ended }
    end

    def check_subtree(subtree, results, target)
      subtree.reduce(results) do |memo, (branch, children)|
        if branch == target || target == :all
          wrap_tree(children, memo)
        elsif children.is_a? Hash
          check_subtree(children, memo, target)
        end

        memo
      end
    end

    def wrap_tree(subtree, results)
      subtree.reduce(results) do |memo, (branch, children)|
        if branch.is_a? Client
          memo += children
        else
          wrap_tree(children, memo)
        end

        memo
      end
    end
end

class ResultOfTestPolicy < ApplicationPolicy
  def edit?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client?
  end

  def update?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client?
  end

  def show?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client? || client? && my_result?
  end

  def index?
    return false unless exist?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor? || client? && my_result?
  end

  def destroy?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client?
  end

  def show_heatmap?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client?
  end

  def summary_results?
    super? || mentor? || local_admin?
  end

  def summary_result?
    super? || me? || local_admin? && (my_mentor? || result_of_my_mentors_client?) || mentor? && result_of_my_client?
  end

  private
    def result_of_my_client?
      my_client?
    end

    def result_of_my_mentors_client?
      client_of_my_mentor?
    end

    def my_result?
      user.client.id == record.client_id
    end
end

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
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client? || client? && me?
  end

  def index?
    return false unless exist?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor? || client? && me?
  end

  def destroy?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client?
  end

  def show_heatmap?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client?
  end

  private
    def result_of_my_client?
      client = record.client
      my_client?(client: client)
    end

    def result_of_my_mentors_client?
      client = record.client
      client_of_my_mentor?(client: client)
    end
end

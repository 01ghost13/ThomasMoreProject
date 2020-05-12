class TestProccessPolicy < ApplicationPolicy

  def answer?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client? || client? && my_result?
  end

  def testing?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client? || client? && my_result?
  end

  def begin?
    return false unless exist?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor? || client? && me?
  end

  def index?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor? || client? && me?
  end

  def finish?
    return false unless exist?
    super? || mentor? && result_of_my_client? || local_admin? && result_of_my_mentors_client? || client? && my_result?
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

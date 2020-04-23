class ClientPolicy < ApplicationPolicy
  def new?
    super? || mail_confirmed? && (local_admin? || mentor?)
  end

  def create?
    super? || mail_confirmed? && (local_admin? || mentor?)
  end

  def edit?
    return false unless exist?
    return false unless active? || super?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor? || client? && me?
  end

  def update?
    return false unless exist?
    return false unless active? || super?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor? || client? && me?
  end

  def show?
    return false unless exist?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor? || client? && me?
  end

  def update_mentors?
    super? || mail_confirmed? && (local_admin? || mentor?)
  end

  def index?
    super? || mail_confirmed? && (local_admin? || mentor?)
  end

  def destroy?
    return false unless exist?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor?
  end

  def mode_settings?
    return false unless exist?
    return false unless active? || super?
    super? || mentor? && my_client? || local_admin? && client_of_my_mentor?
  end
end

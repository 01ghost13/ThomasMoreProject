class MentorPolicy < ApplicationPolicy
  def new?
    super? || mail_confirmed? && local_admin?
  end

  def create?
    super? || mail_confirmed? && local_admin?
  end

  def edit?
    return false unless exist?
    super? || mail_confirmed? && (local_admin? && my_mentor? || mentor? && me?)
  end

  def update?
    return false unless exist?
    super? || mail_confirmed? && (local_admin? && my_mentor? || mentor? && me?)
  end

  def index?
    super? || mail_confirmed? && local_admin?
  end

  def show?
    return false unless exist?
    super? || local_admin? && my_mentor? || mentor? && me?
  end

  def delegate?
    return false unless exist?
    super? || mail_confirmed? && local_admin? && my_mentor?
  end

  def delete?
    return false unless exist?
    super? || mail_confirmed? && local_admin? && my_mentor?
  end
end

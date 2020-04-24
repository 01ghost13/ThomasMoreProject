class AdministratorPolicy < ApplicationPolicy
  # See https://actionpolicy.evilmartians.io/#/writing_policies
  # Scoping
  # See https://actionpolicy.evilmartians.io/#/scoping

  def new?
    super?
  end

  def create?
    super?
  end

  def index?
    super?
  end

  def edit?
    return false unless exist?
    super? || local_admin? && me? && mail_confirmed?
  end

  def update?
    return false unless exist?
    super? || local_admin? && me? && mail_confirmed?
  end

  def show?
    return false unless exist?
    super? || me?
  end

  def delegate?
    return false unless exist?
    super? && !record.super_admin?
  end

  def delete?
    return false unless exist?
    super? && !record.super_admin?
  end
end

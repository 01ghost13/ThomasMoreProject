class TestPolicy < ApplicationPolicy
  def new?
    super?
  end

  def create?
    super?
  end

  def update_image?
    super?
  end

  def edit?
    return false unless exist?
    super?
  end

  def update?
    return false unless exist?
    super?
  end

  def destroy?
    return false unless exist?
    super?
  end

  def index?
    super? || record[:id].present?
  end
end

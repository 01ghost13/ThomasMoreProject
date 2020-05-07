class TestAvailabilityPolicy < ApplicationPolicy
  def index?
    super?
  end

  def batch_update?
    super?
  end
end

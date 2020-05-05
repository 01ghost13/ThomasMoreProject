class TranslationPolicy < ApplicationPolicy
  def index?
    super?
  end

  def update?
    super?
  end

  def create?
    super?
  end

  def create_language?
    super?
  end

  def create_translated_columns?
    super?
  end

  def update_translated_columns?
    super?
  end

end

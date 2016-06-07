class UserPolicy < ApplicationPolicy

  def me?
    user == record
  end

  def show?
    me?
  end

  def create?
    me?
  end

  def update?
    me?
  end

  def destroy?
    me?
  end

end

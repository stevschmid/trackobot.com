class ResultPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      user.results
    end
  end

  def create?
    owner?
  end

  def update?
    owner?
  end

  def destroy?
    owner?
  end

end

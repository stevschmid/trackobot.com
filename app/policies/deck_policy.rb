class DeckPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      user.decks
    end
  end

  def owner?
    record.user_id == user.id
  end

  def show?
    owner?
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

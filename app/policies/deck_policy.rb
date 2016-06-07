class DeckPolicy < ApplicationPolicy

  class Scope < Scope
    def resolve
      Deck.all
    end
  end

  def show?
    true
  end

  def create?
    false
  end

  def update?
    false
  end

  def destroy?
    false
  end

end

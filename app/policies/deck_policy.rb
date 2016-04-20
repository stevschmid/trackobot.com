class DeckPolicy < OwnerPolicy

  class Scope < Scope
    def resolve
      user.decks
    end
  end

end

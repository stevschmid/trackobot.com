class ArenaPolicy < OwnerPolicy

  class Scope < Scope
    def resolve
      user.arenas
    end
  end

end

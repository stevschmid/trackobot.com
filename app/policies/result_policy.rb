class ResultPolicy < OwnerPolicy

  class Scope < Scope
    def resolve
      user.results
    end
  end

end

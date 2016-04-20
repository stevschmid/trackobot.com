class UserPolicy < OwnerPolicy

  def owner?
    user == record
  end

end

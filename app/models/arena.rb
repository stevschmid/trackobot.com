class Arena < ActiveRecord::Base
  paginates_per 10

  belongs_to :hero
  belongs_to :user

  has_many :results

  def wins
    results.wins
  end

  def losses
    results.losses
  end
end

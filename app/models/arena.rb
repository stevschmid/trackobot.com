class Arena < ApplicationRecord
  enum hero: Hero::MAPPING, _suffix: true

  belongs_to :user

  has_many :results

  validates_presence_of :hero, :user

  def wins
    results.wins
  end

  def losses
    results.losses
  end
end

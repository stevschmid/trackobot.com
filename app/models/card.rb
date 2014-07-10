class Card < ActiveRecord::Base
  self.inheritance_column = :_type_disabled

  has_and_belongs_to_many :decks
end

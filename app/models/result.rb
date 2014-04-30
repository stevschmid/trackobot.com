class Result < ActiveRecord::Base
  enum mode: [:ranked, :casual, :practice, :arena]

  belongs_to :hero
  belongs_to :opponent, class_name: 'Hero'

  belongs_to :user

  scope :wins, ->{ where(win: true) }
  scope :losses, ->{ where(win: false) }

  def hero=(hero)
    if hero.kind_of?(String)
      hero = Hero.where('lower(name) = ?', hero.downcase).first
    end
    super(hero)
  end

  def opponent=(opponent)
    if opponent.kind_of?(String)
      opponent = Hero.where('lower(name) = ?', opponent.downcase).first
    end
    super(opponent)
  end
end

class UsersController < ApplicationController

  respond_to :json

  skip_before_action :authenticate_user!, only: [:create]

  before_action :check_ip_spam, only: [:create]

  def create
    username = generate_unique_username
    @generated_password = generate_password
    @user = User.create(username: username,
                        password: @generate_password,
                        password_confirmation: @generate_password,
                        sign_up_ip: ip_address)
    respond_with(@user)
  end

  private

  def ip_address
    request.env['REMOTE_ADDR']
  end

  def check_ip_spam
    if User.where(sign_up_ip: ip_address)
           .where('created_at > ?', 1.hour.ago).count >= 3
    then
      render nothing: true, status: 429
    end
  end

  NAME_ADJECTIVES = [
    "autumn", "hidden", "bitter", "misty", "silent", "empty", "dry", "dark",
    "summer", "icy", "delicate", "quiet", "white", "cool", "spring", "winter",
    "patient", "twilight", "dawn", "crimson", "wispy", "weathered", "blue",
    "billowing", "broken", "cold", "damp", "falling", "frosty", "green",
    "long", "late", "lingering", "bold", "little", "morning", "muddy", "old",
    "red", "rough", "still", "small", "sparkling", "throbbing", "shy",
    "wandering", "withered", "wild", "black", "young", "holy", "solitary",
    "fragrant", "aged", "snowy", "proud", "floral", "restless", "divine",
    "polished", "ancient", "purple", "lively", "nameless"
  ]

  NAME_NOUNS = ["Magma Rager", "Mana Wraith", "Mad Bomber", "Leper Gnome", "Mana Wyrm", "Secretkeeper", "Kidnapper", "Hyena", "Onyxia", "Raid Leader", "Ancient Mage", "Boar", "Malygos", "Molten Giant", "Flame Imp", "Voidwalker", "Wolfrider", "Nozdormu", "Imp", "Alexstrasza", "Defender", "Sunwalker", "Mirror Image", "Gnoll", "Wisp", "Imp Master", "Nat Pagle", "Timber Wolf", "Blood Knight", "SI7 Agent", "Sheep", "Dalaran Mage", "Lightwell", "Spellbreaker", "Mana Addict", "Core Hound", "Ysera", "Abomination", "Hungry Crab", "Blood Imp", "Whelp", "War Golem", "Treant", "Misha", "Loot Hoarder", "Snake", "Felguard", "Lightwarden", "Deathwing", "Demolisher", "Spirit Wolf", "Void Terror", "Tundra Rhino", "Lightspawn", "Houndmaster", "Doomsayer", "Arcane Golem", "AlarmoBot", "Azure Drake", "Treant", "Cenarius", "Dust Devil", "The Beast", "Baron Geddon", "Gruul", "Archmage", "King Mukla", "Elven Archer", "Succubus", "Windspeaker", "Infernal", "Hogger", "Squire", "Frog", "King Krush", "Nightblade", "Pit Lord", "Treant", "Armorsmith", "Old MurkEye", "Ogre Magi", "Murloc Scout", "Cult Master", "Squirrel", "Panther", "Shieldbearer", "Ironbeak Owl", "Doomguard", "Sea Giant"]

  def generate_unique_username
    loop do
      username = [NAME_ADJECTIVES.sample, NAME_NOUNS.sample, rand(1000...10000)].join(' ').gsub(' ', '-').downcase
      break username unless User.where(username: username).first
    end
  end

  def generate_password
    SecureRandom.hex(5)
  end
end

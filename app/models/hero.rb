class Hero
  MAPPING = {
    priest: 1,
    rogue: 2,
    mage: 3,
    paladin: 4,
    warrior: 5,
    warlock: 6,
    hunter: 7,
    shaman: 8,
    druid: 9,
    demon_hunter: 10,
  }

  LIST = MAPPING.keys.map(&:to_s)
end

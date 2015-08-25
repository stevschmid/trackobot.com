class Result
  class CardHistoryListCoder
    # first 1: player
    # next 7 bits: turn counter
    # remaining 24 bits: card_id

    def self.dump list
      list ||= []

      raw_list = list.collect do |obj|
        {
          self: obj.player == :me,
          turn: obj.turn,
          card_id: obj.card.id
        }
      end

      # now convert the list of hashes into the binary format
      raw_list.collect do |obj|
        (
          (
            (obj[:self] ? 0x80 : 0) |
            ((obj[:turn] || 0) & 0x7F)
          ) << 24
        ) |
          obj[:card_id] & 0xFFFFFF
      end.pack("I*")
    end

    def self.load data
      return [] if data.nil?
      raw_list = data.unpack("I*").collect do |i|
        {
          self: (i >> 24) & 0x80 > 0,
          turn: (i >> 24) & 0x7F,
          card_id: (i & 0xFFFFFF)
        }
      end

      # preload cards
      card_ids = raw_list.collect { |e| e[:card_id] }
      cards = Card.where(id: card_ids).index_by(&:id)

      # convert list of hashes into card history list
      raw_list.collect do |entry|
        CardHistoryEntry.new(player: entry[:self] ? :me : :opponent,
                             turn: entry[:turn],
                             card: cards[entry[:card_id]])
      end
    end

  end


end

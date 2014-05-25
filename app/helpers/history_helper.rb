module HistoryHelper

  def table_of_cards_played(card_history)
    return nil if card_history.empty?

    table = "<table class='card_history'>" + card_history.group(:card).count.sort_by do |card, count|
      card.mana || -1
    end.collect do |card, count|
      "<tr><td><div class='mana'>#{card.mana || 0}</div>&nbsp;#{card.name} #{"(#{count})" if count > 1}</td></tr>"
    end.join + "</table>"

    table.html_safe
  end

end

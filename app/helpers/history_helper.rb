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

  def timeline(result)
    chronological_card_history = result.card_histories.order(:created_at)

    history_by_player = {'me' => [], 'opponent' => []}

    current_plays = []
    current_player = nil

    chronological_card_history.each do |card_history|
      if current_player && current_player != card_history.player
        history_by_player[current_player] << current_plays
        current_plays = []
      end
      current_player = card_history.player
      current_plays << card_history
    end

    if current_plays.any?
      history_by_player[current_player] << current_plays
    end

    li = []
    history_by_player.each do |player, grouped_card_histories|
      grouped_card_histories.each do |card_histories|
        history = []

        card_histories.each do |card_history|
          history << content_tag(:div, "<div class='mana'>#{card_history.card.mana || 0}</div>&nbsp;".html_safe + card_history.card.name, class: 'card')
        end

        li << content_tag(:li, history.join.html_safe, class: player)
      end
    end

    content_tag(:ol, li.join.html_safe, class: 'timeline')
  end
end

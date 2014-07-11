module HistoryHelper

  def table_of_cards_played(card_histories)
    return nil if card_histories.empty?

    cards = {me: [], opponent: []}

    # use ruby approach because we use eager loaded objects
    card_histories.each do |card_history|
      if card_history.me?
        cards[:me] << card_history.card
      else
        cards[:opponent] << card_history.card
      end
    end

    result = {}

    %i[me opponent].each do |x|
      cards_by_mana = cards[x].group_by { |card| card }.sort_by { |card, _| card.mana || -1 }
      next if cards_by_mana.empty?
      result[x] = "<table class='card_history'>" + cards_by_mana.collect do |card, array|
        "<tr><td><div class='mana'>#{card.mana || 0}</div>&nbsp;#{card.name} #{"(#{array.length})" if array.length > 1}</td></tr>"
      end.join + "</table>"
    end

    result
  end

  def timeline_header_of_result(result)
    content_tag(:div, class: 'timeline-header') do
      if result.coin
        hero_appendix = ' <small>2nd</small>'.html_safe
        opponent_appendix = ' <small>1st</small>'.html_safe
      else
        hero_appendix = ' <small>1st</small>'.html_safe
        opponent_appendix = ' <small>2nd</small>'.html_safe
      end
      [content_tag(:div, player_label_for_result(result) + hero_appendix), content_tag(:div, opponent_label_for_result(result) + opponent_appendix)].join.html_safe
    end
  end

  def timeline_of_result(result)
    chronological_card_history = result.card_histories

    card_groups = []

    current_card_group = []
    current_player = nil

    chronological_card_history.each do |card_history|
      if current_player && current_player != card_history.player
        card_groups << current_card_group
        current_card_group = []
      end
      current_player = card_history.player
      current_card_group << card_history
    end

    if current_card_group.any?
      card_groups << current_card_group
    end

    list = []
    card_groups.each do |card_group|
      cards = []
      card_group.each do |card_history|
        cards << content_tag(:div, "<div class='mana'>#{card_history.card.mana || 0}</div>&nbsp;".html_safe + card_history.card.name, class: 'card')
      end
      list << content_tag(:li, cards.join.html_safe, class: card_group.first.player)
    end

    content_tag(:ol, list.join.html_safe, class: 'timeline')
  end
end

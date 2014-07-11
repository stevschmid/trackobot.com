module ApplicationHelper
  def nav_link(link_text, link_path, root = false)
    current = current_page?(link_path)
    current ||= root && current_page?(profile_path)

    class_name = current ? 'active' : ''

    content_tag(:li, :class => class_name) do
      link_to link_text, link_path
    end
  end

  def hero_label(hero_name, label = hero_name, additions = {})
    [
      hero_icon(hero_name),
      content_tag(:span, label, additions)
    ].join(' ').html_safe
  end

  def player_label_for_result(result, additions = {})
    if result.deck
      label_for_deck(result.deck, additions)
    else
      hero_label(result.hero.name, result.hero.name, additions)
    end
  end

  def opponent_label_for_result(result, additions = {})
    if result.opponent_deck
      label_for_deck(result.opponent_deck, additions)
    else
      hero_label(result.opponent.name, result.opponent.name, additions)
    end
  end

  def label_for_deck(deck, additions = {})
    hero_label(deck.hero.name, deck.name, additions)
  end

  def hero_icon(hero_name, additions = {})
    image_tag("classes/#{hero_name.downcase}.png", {width: '20px'}.merge(additions))
  end

  def show_feedback_button?
    current_user.feedbacks.where('created_at > ?', 1.day.ago).none?
  end

  def title(title)
    content_for :title, title
  end
end


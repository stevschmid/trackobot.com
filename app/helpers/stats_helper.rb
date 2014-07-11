module StatsHelper
  def win_rate(num_wins, num_losses)
    return '-' if num_wins + num_losses == 0
    ratio = if num_wins + num_losses > 0
              num_wins.to_f / (num_wins + num_losses)
            else
              0
            end

    content_tag :div do
      [
        (ratio * 100.0).round(1).to_s + '%',
        content_tag(:span, "#{num_wins}/#{num_wins + num_losses}", class: 'pie')
      ].join(' ').html_safe
    end
  end
end

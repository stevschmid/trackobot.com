module StatsHelper
  def winrate(num_wins, num_losses, classes = [])
    return '-' if num_wins + num_losses == 0
    ratio = if num_wins + num_losses > 0
              num_wins.to_f / (num_wins + num_losses)
            else
              0
            end

    content_tag :div do
      [
        content_tag(:span, (ratio * 100.0).round(1).to_s + '%', class: classes + ['winrate']),
        content_tag(:span, "#{num_wins}/#{num_wins + num_losses}", class: 'pie')
      ].join(' ').html_safe
    end
  end

  def win_loss(num_wins, num_losses)
    return '-' if num_wins == 0 and num_losses == 0
    "#{num_wins}<small class='win-loss-unit'>W</small> #{num_losses}<small class='win-loss-unit'>L</small>".html_safe
  end

  def percentage(x, total, digits = 1, classes = [])
    return '-' if total == 0
    ratio = x.to_f / total
    content_tag(:span, (ratio * 100.0).round(digits).to_s + '%', class: classes + ['percentage'])
  end

  def ratio(x, y)
    return '-' unless y and y != 0
    "%.1f" % (x.to_f / y)
  end

  def sortable_header_link(label, sort_by)
    if @sort_by == sort_by
      order = @order == :asc ? :desc : :asc
      label = [label, icon("sort-#{@order}")].join(' ').html_safe
    else
      order = Stats::DEFAULT_ORDER
    end

    link_to label, stats_params.merge(sort_by: sort_by, order: order)
  end

  def stats_params
    params.permit(*Stats::PARAMS)
  end
end

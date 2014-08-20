module StatsHelper
  def winrate(num_wins, num_losses)
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

  def percentage(x, total, digits = 1, pie = true)
    return '-' if total == 0
    ratio = x.to_f / total

    content_tag :div do
      [
        (ratio * 100.0).round(digits).to_s + '%',
        pie ? content_tag(:span, "#{x}/#{total}", class: 'pie') : nil
      ].compact.join(' ').html_safe
    end
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

    link_to label, params.merge(sort_by: sort_by, order: order)
  end
end

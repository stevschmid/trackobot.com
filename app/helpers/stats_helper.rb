module StatsHelper
  def win_rate(num_wins, num_losses)
    ratio = if num_wins + num_losses > 0
              num_wins.to_f / (num_wins + num_losses)
            else
              0
            end
    (ratio * 100.0).round(1).to_s + '%'
  end
end

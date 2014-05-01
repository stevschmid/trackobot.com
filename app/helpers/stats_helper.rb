module StatsHelper
  def win_rate(num_wins, num_losses)
    ratio = num_wins.to_f / (num_wins + num_losses)
    (ratio * 100.0).round(1).to_s + '%'
  end
end

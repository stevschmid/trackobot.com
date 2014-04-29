module ResultsHelper
  def ratio(value, total)
    (value.to_f / total.to_f * 100.0).round(2).to_s + '%'
  end
end

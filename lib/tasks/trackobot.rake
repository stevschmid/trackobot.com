namespace :trackobot do
  task :migrate_card_histories_data => :environment do
    max_id = Result.maximum(:id)

    cards_by_id = Card.all.index_by(&:id)

    ActiveRecord::Base.logger = nil
    Result.find_each do |result|
      next if result.card_history_data?
      if result.id % 1000 == 0
        puts "#{result.id} #{result.id/max_id.to_f * 100.0}%"
        $stdout.flush
      end

      sql = "SELECT * FROM card_histories WHERE result_id = #{result.id} ORDER BY id"
      card_histories = ActiveRecord::Base.connection.execute(sql)

      list = card_histories.collect do |ch|
        CardHistoryEntry.new(
          card: cards_by_id[ ch['card_id'].to_i ],
          turn: ch['turn'].present? ? ch['turn'].to_i : 0,
          player: ch['player'].to_i == 0 ? :me : :opponent
        )
      end

      unless list.empty?
        result.card_history_list = list
        result.save!
      end
    end
  end
end


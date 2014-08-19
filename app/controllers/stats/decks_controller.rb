class Stats::DecksController < ApplicationController
  respond_to :json, :html

  include Stats

  def index
    @stats = {
      overall: {
        wins: user_results.wins.count,
        losses: user_results.losses.count,
        total: user_results.count
      },
      as_deck: {},
      vs_deck: {}
    }

    user_results.group(:win, :deck_id).count.each do |(win, deck_id), count|
      next unless deck_id and current_user.decks.find_by_id(deck_id)
      stat = (@stats[:as_deck][current_user.decks.find(deck_id)] ||= {wins: 0, losses: 0, total: 0})
      stat[(win ? :wins : :losses)] += count
      stat[:total] += count
    end

    user_results.group(:win, :opponent_deck_id).count.each do |(win, deck_id), count|
      next unless deck_id and current_user.decks.find_by_id(deck_id)
      stat = (@stats[:vs_deck][current_user.decks.find(deck_id)] ||= {wins: 0, losses: 0, total: 0})
      stat[(win ? :wins : :losses)] += count
      stat[:total] += count
    end

    respond_to do |format|
      format.html
      format.json do
        render json: {stats: @stats}
      end
    end
  end

end

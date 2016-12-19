namespace :trackobot do
  # Meta shifts, new decks get added
  # -> We need to reduce the sum of gradients
  # -> Learning gets easier
  task :classifier_decay => :environment do
    DECAY_HALF_TIME = 30.days
    LABMDA = Math.log(2) / DECAY_HALF_TIME

    Deck.find_each do |deck|
     t  = Time.now - (deck.last_decay_at || Time.now)
     scale = Math.exp(-t*LAMBDA)

     Rails.logger.info "[Classify] Decay deck #{deck.full_name}: #{scale}"
     deck.classifier.scale_sum_gradient_by(scale)
     deck.last_decay_at = Time.now
     deck.save!
    end
  end
end

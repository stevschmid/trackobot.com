every 1.day, at: '10:00am' do
  rake 'trackobot:decay_classifiers'
end

every 1.day, at: '10:30am' do
  rake 'trackobot:vacuum_card_history'
end


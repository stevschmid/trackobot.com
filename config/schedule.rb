every 1.day, at: '10:00am' do
  rake 'trackobot:classifier_decay'
end

every 1.day, at: '10:30am' do
  rake 'trackobot:vacuum_card_history'
end


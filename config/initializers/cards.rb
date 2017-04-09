require 'open-uri'
url = 'https://api.hearthstonejson.com/v1/latest/enUS/cards.json'
data = URI.parse(url).read
CARDS = JSON.parse(data, object_class: OpenStruct).index_by(&:id)

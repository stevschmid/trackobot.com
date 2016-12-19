CARDS = JSON.parse(File.read(File.join(Rails.root, 'db', 'cards.json')), object_class: OpenStruct).index_by(&:id)

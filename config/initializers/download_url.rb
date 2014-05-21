require 'rexml/document'
require 'time'

def version_as_int(version)
  version.to_s.gsub(/\D/, '').to_i
end

doc = REXML::Document.new(File.open('public/appcast.xml'))
items = doc.elements.collect('*/channel/item') do |item|
  item
end
latest_item = items.max do |a, b|
  version_as_int(a.elements['enclosure'].attributes['sparkle:version']) <=> version_as_int(b.elements['enclosure'].attributes['sparkle:version'])
end

DOWNLOAD_URL = latest_item.elements['enclosure'].attributes['url']


require 'open-uri'

releases = JSON.load(open('https://api.github.com/repos/stevschmid/track-o-bot/releases'))
latest_release = releases.max_by do |rel|
  Time.parse(rel['published_at'])
end

asset = latest_release['assets'].find { |asset| asset['name'].index('.dmg') }

DOWNLOAD_URL_MAC = latest_release['html_url'].gsub('/tag/', '/download/') + '/' + asset['name']


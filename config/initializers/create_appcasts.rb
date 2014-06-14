require 'open-uri'

releases = JSON.load(open('https://api.github.com/repos/stevschmid/track-o-bot/releases'))
# sort version DESCENDING cuz WinSparkle cannot handle the truth and takes the top item as the newest one...
# once in my lifetime I'd like to work with experts, ONCE
releases.sort_by! { |rel| Gem::Version.new(rel['tag_name']) }.reverse!

mac_releases = releases.select do |rel|
  rel['assets'].any? { |a| a['name'].index('.dmg') }
end
latest_mac_release = mac_releases.max_by { |rel| Gem::Version.new(rel['tag_name']) }
if latest_mac_release
  mac_asset = latest_mac_release['assets'].find { |asset| asset['name'].index('.dmg') }
  MAC_DOWNLOAD_URL = latest_mac_release['html_url'].gsub('/tag/', '/download/') + '/' + mac_asset['name']
end

win_releases = releases.select do |rel|
  rel['assets'].any? { |a| a['name'].index('.exe') }
end
latest_win_release = win_releases.max_by { |rel| Gem::Version.new(rel['tag_name']) }
if latest_win_release
  win_asset = latest_win_release['assets'].find { |asset| asset['name'].index('.exe') }
  WIN_DOWNLOAD_URL = latest_win_release['html_url'].gsub('/tag/', '/download/') + '/' + win_asset['name']
end

[
  [:mac, 'appcast.xml', '.dmg', mac_releases],
  [:win, 'appcast_win.xml', '.exe', win_releases]
].each do |(_, appcast_file, asset_extension, releases)|
  builder = Builder::XmlMarkup.new(indent: 2)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  builder.instruct! :xml, encoding: 'UTF-8', version: '1.0'
  builder.rss 'xmlns:sparkle' => 'http://www.andymatuschak.org/xml-namespaces/sparkle',
              'xmlns:dc' => 'http://purl.org/dc/elements/1.1/',
              'version' => '2.0' do |rss|

    rss.channel do |channel|
      rss.title "Track-o-Bot's Changelog"
      rss.link "https://trackobot.com/appcast.xml"
      rss.description "Most recent changes with links to updates."
      rss.language "en"

      releases.each do |rel|
        next if rel['prerelease'] # skip prereleases in the appcast

        rss.item do |item|
          item.title rel['name']
          item.description do |description|
            html = '<style type="text/css">* { font-family: Arial, Helvetica, sans-serif; }</style>' + markdown.render(rel['body'])
            description.cdata!(html)
          end
          item.pubDate Time.parse(rel['published_at']).strftime('%a, %d %b %Y %H:%M:%S %z')

          asset = rel['assets'].find { |a| a['name'].index(asset_extension) }
          dl_url = rel['html_url'].gsub('/tag/', '/download/') + '/' + asset['name']
          item.enclosure url: dl_url, 'sparkle:version' => rel['tag_name'], length: asset['size'], type: asset['content_type']
        end
      end
    end
  end

  File.write(File.join(Rails.root, 'public', appcast_file), builder.target!)
end


require 'open-uri'

def download_link(track)
  url = "https://api.soundcloud.com/tracks/#{track.id}/stream?client_id=#{Rails.configuration.sc_client_id}"
  File.open("songs/#{track.title}.mp3", "wb") do |file|
    file.write open(url).read
    puts "Saved #{track.title}"
  end
end

namespace :db do
  desc 'Call the soundcloud API and make magic happen'
  task :scrape_links => [:environment] do |t|
    client = Soundcloud.new(:client_id => Rails.configuration.sc_client_id,
                        :client_secret => Rails.configuration.sc_client_secret,
                        :username      => Rails.configuration.sc_user,
                        :password      => Rails.configuration.sc_pass)
    playlist = client.get('/me/playlists').first
    tracks = playlist.tracks
    tracks.each do |x|
      download_link(x)
    end
  end
end
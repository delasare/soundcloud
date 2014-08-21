require 'open-uri'
require 'mongo'
include Mongo

def download_link(track)
  file_path = "songs/#{track.title}.mp3"
  if File.exist?("songs/#{track.title}.mp3")
    puts "File already exists"
  else
    url = "https://api.soundcloud.com/tracks/#{track.id}/stream?client_id=#{Rails.configuration.sc_client_id}"
    File.open(file_path, "wb") do |file|
      file.write open(url).read
      puts "Saved #{track.title}"
    end
  end
end

def get_db()
  return Connection.new.db('soundcloud')
end

namespace :db do
  desc 'Call the soundcloud API and make magic happen'
  task :scrape_links => [:environment] do |t|
      db = Connection.new.db('soundcloud')
    songs = db.collection('songs')
    client = Soundcloud.new(:client_id => Rails.configuration.sc_client_id,
                        :client_secret => Rails.configuration.sc_client_secret,
                        :username      => Rails.configuration.sc_user,
                        :password      => Rails.configuration.sc_pass)
    playlist = client.get('/me/playlists').first
    tracks = playlist.tracks
    tracks.each do |x|

      puts "Retrieving: #{x["track_id"]} #{x["title"]}"
      songs.update(
        { "track_id" => x.id},
        { "$push" => { "songs" => { "track_id" => x.id, "title" => x.title, "created_on" => Time.now }}},
        :upsert => true, :safe => true
      )

      download_link(x)
    end
  end
  
  task :list_tracks => [:environment] do |t|
    db = Connection.new.db('soundcloud')
    row = db.collection('songs').find()
    row.each do |x|
      puts "#{x["track_id"]} #{x["title"]}"
    end
  end
  
  task :setup_db => [:environment] do |t|
    db = get_db()
    db.collection("songs").ensure_index(:track_id, :unique => true)

    unless Dir.exists?('songs')
      Dir.mkdir 'songs'
    end
  end  
end
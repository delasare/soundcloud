require 'open-uri'
require 'mongo'
include Mongo

class SongsController < ApplicationController
  
  def index
    @songs_array = []
    db = Connection.new.db('soundcloud')
    row = db.collection('songs').find()
    row.each do |x|
      s = "#{x["track_id"]}: #{x["songs"][0]["title"]}".gsub(/["]/, '') # + x.inspect
      @songs_array << s
    end
  	#render text: text
  end
end

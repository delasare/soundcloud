require 'open-uri'
require 'mongo'
include Mongo

class SongsController < ApplicationController
  
  def index
    text = ""
    db = Connection.new.db('soundcloud')
    row = db.collection('songs').find()
    row.each do |x|
      text = text + "<p>#{x["track_id"]}: #{x["songs"][0]["title"]}</p>".gsub(/["]/, '') # + x.inspect
    end
  
  	render text: text
  end
end

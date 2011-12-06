require  'rubygems'
require  'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'mongo'
require 'awesome_print'
require 'Map'
require 'helpers'

SERVER = '127.0.0.1'
#SERVER = '192.168.0.100'
DATABASE = 'holiday'
SONGS = 'song_list'
OUTPUT = 'output'

@con = Mongo::Connection.new(SERVER)
@@db = @con[DATABASE]
@@song_list = @@db[SONGS]
@@output = @@db[OUTPUT]


get "/" do
  @@songs = @@db[SONGS].find.limit(20).to_a
  haml :index 
end

get '/station/:station' do
  @station = params[:station]
  @count = @@song_list.find({:station=> params[:station]}).count
  haml :station
end

get '/station_list' do
  map = Map.new(@@song_list)
  coll = map.count_by("station")
  @results = @@output.find({}).sort("value", :desc)
  haml :station_list
end

get '/date_list' do
  map = Map.new(@@song_list)
  map.count_item_by_day("station")
  @results = map
  
  haml :date_list
end

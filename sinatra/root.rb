require  'rubygems'
require  'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'mongo'
require 'awesome_print'
require 'Map'
require 'helpers'

@con = Mongo::Connection.new
@@db = @con['holiday']
cursor = @@db['songs'].find({})
@@song_list = @@db['songs']
@@output = @@db['output']
@@songs = cursor.limit(20)


get "/" do
  @@songs.rewind!
  haml :index 
end

get '/station/:station' do
  @station = params[:station]
  @count = @@db['songs'].find({:station=> params[:station]}).count
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
  coll = map.count_item_by_day("station")
  @results = @@output.find({}).sort("station", :desc)
  haml :date_list
end

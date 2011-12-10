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
#SONGS = 'songs_t'
SONGS = 'song_list'
OUTPUT = 'output'
RELATED = ["title", "by", "station"]

@con = Mongo::Connection.new(SERVER)
@@db = @con[DATABASE]
@@song_list = @@db[SONGS]
@@output = @@db[OUTPUT]


get "/" do
  @@songs = @@db[SONGS].find.limit(20).sort("at", :desc).to_a
  haml :index 
end

get '/station/:station' do
  @station = params[:station]
  @count = @@song_list.find({:station=> params[:station]}).count
  haml :station
end

get '/list/:item/?:sort_by?/?:sort_order?/?:skip_value?' do
  
  @item = params[:item]
  @sort_by = params[:sort_by] ||= 'value'
  @order = Mongo::ASCENDING 
  @sort_order = params[:sort_order] ||= 'asc'
  @skip_value = params[:skip_value].to_i ||= 0
  @last_link  = "/list/#{@item}/#{@sort_by}/#{@sort_order}/#{@skip_value - 20}"
  @next_link = "/list/#{@item}/#{@sort_by}/#{@sort_order}/#{@skip_value + 20}" 
  @detail_link = "/detail/#{@item}/"
  if @sort_order == "desc" then
    order = Mongo::DESCENDING
  end
  map = Map.new(@@song_list)
  coll = map.count_by(@item)
  @count = @@output.count
  @results = @@output.find({}).sort(@sort_by, order).skip(@skip_value).limit(20)
  haml :list
end


get '/detail/:item/:value' do
  @value = params[:value]
  @item = params[:item]

  map = Map.new(@@song_list)
  map.count_by_filtered(@item, @value, @item)
  @results = @@output.find_one()
  @relate = RELATED - [@item]
  @out = Hash.new
  @relate.each do |rel|
    @out[rel] = map.count_by(rel, "out_#{rel}", @item, @value)
  end

  haml :detail

end


get '/date_list' do
  map = Map.new(@@song_list)
  map.count_item_by_day("station")
  @results = map
  
  haml :date_list
end


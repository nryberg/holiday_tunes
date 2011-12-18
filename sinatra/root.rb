require  'rubygems'
require  'sinatra'
require "sinatra/reloader" if development?
require 'haml'
require 'mongo'
require 'awesome_print'
require 'Map'
require 'helpers'

enable :sessions

SERVER = '127.0.0.1'
#SERVER = '192.168.0.100'
DATABASE = 'holiday'
#SONGS = 'songs_t'
RENAME = 'rename'
SONGS = 'song_list'
OUTPUT = 'output'
RELATED = ["title", "by", "station"]

@con = Mongo::Connection.new(SERVER)
@@db = @con[DATABASE]
@@song_list = @@db[SONGS]
@@output = @@db[OUTPUT]
@@renamed = @@db[RENAME]


get "/?:skip_value?" do
  @skip_value = params[:skip_value].to_i || 0
  @count = @@song_list.count()
  @@songs = @@db[SONGS].find.limit(20).skip(@skip_value).sort("at", :desc).to_a
  haml :index 
end

get '/station/:station' do
  @station = params[:station]
  @count = @@song_list.find({:station=> params[:station]}).count
  
  haml :station
end

get '/flag/:num/:item/:value' do
  flag = "flag#{params[:num]}"
  session[flag] = params[:value]
  session[:item] = params[:item]
  redirect session[:last_query]

end

get '/list/:item/?:sort_by?/?:sort_order?/?:skip_value?' do
  session[:last_query] = request.fullpath  
  @item = params[:item]
  @sort_by = params[:sort_by] ||= 'value'
  @order = Mongo::ASCENDING 
  @sort_order = params[:sort_order] ||= 'asc'
  @skip_value = params[:skip_value].to_i ||= 0
  @last_link  = "/list/#{@item}/#{@sort_by}/#{@sort_order}/#{@skip_value - 20}"
  @next_link = "/list/#{@item}/#{@sort_by}/#{@sort_order}/#{@skip_value + 20}" 
  if @sort_order == "desc" then
    order = Mongo::DESCENDING
  end
  map = Map.new(@@song_list)
  coll = map.count_by(@item)
  @count = @@output.count
  @results = @@output.find({}).sort(@sort_by, order).skip(@skip_value).limit(20)
  haml :list_edit
end


get '/detail/:item/:index' do
  @item = params[:item]
  @index = params[:index]
  
  line =  @@db["out_#{@item}"].find_one({:index => @index})
  ap line

  map = Map.new(@@song_list)
  @item_count = @@song_list.find({@item => @value}).count()
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

get '/pairup' do
  haml :pairup
end

get '/prefer/:num' do
  num = params[:num].to_i
  if num == 1 then 
    @to = session[:flag1]
    @from = session[:flag2]
  else 
    @to = session[:flag2]
    @from = session[:flag1]
  end
    
  replaced = session
  hashbrowns = {:item => session[:item],
                              :from => @from,
                              :to => @to}
  @rename = @@renamed.find(hashbrowns)
  unless @rename.count() > 0 then
    @@renamed.insert(hashbrowns)
  end
  haml :prefer
end


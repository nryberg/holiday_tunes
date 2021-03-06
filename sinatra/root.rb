require  'sinatra'
#require "sinatra/reloader" if development?
require 'haml'
require 'mongo'

require 'awesome_print'
require_relative 'Map'
require_relative 'helpers'

enable :sessions

SERVER = '127.0.0.1'
user = 'santa'
pwd = 'holly'
port = '10093'
SERVER = 'alex.mongohq.com'
SERVER = '192.168.0.100'
DATABASE = 'holiday_2'
SONGS = 'log'
SONGS = 'song_list_2013'
RENAME = 'rename'
OUTPUT = 'output'
RELATED = ["title", "by", "station", "day", "time"]

@con = Mongo::Connection.new(SERVER, port)
@@db = @con[DATABASE]
@@db.authenticate(user, pwd)
@@song_list = @@db[SONGS]
@@output = @@db[OUTPUT]
@@renamed = @@db[RENAME]

get '/sample_data' do
  @songs = @@db['KQQL']
  haml :sample
end

get '/pairup' do
  @item = session[:item]
  @output = "out_#{@item}"
  @first = @@db[@output].find_one(:index => session["flag1"].to_i)
  @second = @@db[@output].find_one(:index => session["flag2"].to_i)
  haml :pairup
end

get '/date_list' do
  map = Map.new(@@song_list)
  map.count_item_by_day("station")
  @results = map
  
  haml :date_list
end

get '/station/:station' do
  @station = params[:station]
  @count = @@song_list.find({:station=> params[:station]}).count
  
  haml :station
end

get '/flag/:num/:item/:index' do
  flag = "flag#{params[:num]}"
  session[flag] = params[:index].to_i
  session[:item] = params[:item]
  redirect session[:last_query]


end

get '/list/:item/?:sort_by?/?:sort_order?/?:skip_value?' do
  session[:last_query] = request.fullpath  
  @item = params[:item]
  session[:item] = params[:item]
  @sort_by = params[:sort_by] ||= 'value'
  @order = Mongo::ASCENDING 
  @output = "out_#{@item}"
  @sort_order = params[:sort_order] ||= 'asc'
  @skip_value = params[:skip_value].to_i ||= 0
  @last_link  = "/list/#{@item}/#{@sort_by}/#{@sort_order}/#{@skip_value - 20}"
  @next_link = "/list/#{@item}/#{@sort_by}/#{@sort_order}/#{@skip_value + 20}" 
  if @sort_order == "desc" then
    order = Mongo::DESCENDING
  end
  @count = @@db[@output].count
  @results = @@db[@output].find({}).sort(@sort_by, order).skip(@skip_value).limit(20)
  haml :list_edit
end


get '/detail/:item/:index' do
  @item = params[:item]
  @index = params[:index]
  @output = "out_#{@item}"
    
  line =  @@db[@output].find_one(BSON::ObjectId(@index))
  @id = line["_id"]
  @name = line["name"]
  @item_count = @@song_list.find({@item => @name}).count()
  @relate = RELATED - [@item]
  @relate_data = Hash.new
  @relate.each do |rel|
    outfile = "out_#{rel}"
    arr = @@song_list.group({:key => "#{rel}", 
                      :initial => {:count => 0},
                      :reduce => "function(x,y){y.count++}",
                      :cond => {@item => @name}
                      })
    arr.each_index do |index|
      search_term = arr[index][rel]
      ap search_term
      ap outfile
      search_line = @@db[outfile].find_one({:name => search_term})
      ap search_line
      search_line = @@db[outfile].find_one({:name => search_term})["_id"]
      arr[index]["_id"] = search_line 
    end
    @relate_data[rel] = arr.sort {|a, b| b["count"] <=> a["count"]} 
  end
  haml :detail

end



get '/prefer/:num' do
  num = params[:num].to_i
  if num == 1 then 
    @to_id = session[:flag1]
    @from_id = session[:flag2]
  else 
    @to_id = session[:flag2]
    @from_id = session[:flag1]
  end
  @from = @@db["out_#{session[:item]}"].find_one(:index => @from_id)["_id"] 
  @to = @@db["out_#{session[:item]}"].find_one(:index => @to_id)["_id"] 
  replaced = session
  hashbrowns = {:item => session[:item],
                              :from => @from,
                              :to => @to}
  @rename = @@renamed.find(hashbrowns)
  unless @rename.count() > 0 then
    @@renamed.insert(hashbrowns)
  end
  process_run_rename
  haml :prefer
end

get '/rename/:item/:index' do 
  @item = params[:item]
  @index = params[:index].to_i
  @output = "out_#{@item}"
  ap [@item, @index, @output]
  line =  @@db[@output].find_one({:index => @index})
  ap line
  @value = line["_id"]
end
get '/renames' do

  haml :renames
end

get "/?:skip_value?" do
  @skip_value = params[:skip_value].to_i || 0
  @count = @@song_list.count()
  @@songs = @@db[SONGS].find.limit(20).skip(@skip_value).sort("at", :desc).to_a
  haml :index 
end



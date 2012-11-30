#!/usr/bin/env  rvm 1.9.3 do ruby

require 'mongo'
require 'awesome_print'
require_relative 'sinatra/Map'
#SERVER = '127.0.0.1'
pwd = 'sffK7mnJ7LWh'
SERVER ='alex.mongohq.com'
PORT = '10093'
#SERVER = '192.168.0.100'
DATABASE = 'holiday_2012'
SONGS = 'log'
#SONGS = 'song_list'
RENAME = 'rename'
OUTPUT = 'output'
RELATED = ["title", "by", "station"]

@con = Mongo::Connection.new(SERVER, PORT)
@@db = @con[DATABASE]
auth = @@db.authenticate('admin', pwd)

@@song_list = @@db[SONGS]
@@output = @@db[OUTPUT]
@@renamed = @@db[RENAME]

@@db.drop_collection('out_title')
@@db.drop_collection('out_by')
@@db.drop_collection('out_station')
@@db.drop_collection('out_day')
@@db.drop_collection('out_time')

map = Map.new(@@song_list)

ap 'Title'
map.group_by('title', 'out_title')

ap 'By'
map.group_by('by', 'out_by')

ap 'Station'
map.group_by('station', 'out_station')

ap 'Days'
@@song_list.find({}, {:fields => [:at]}).each do |entry|
  day =  entry["at"].strftime("%Y-%m-%d %a")
  @@song_list.update({"_id" => entry["_id"]}, {"$set" => {"day" => day}})
end

map.group_by('day', 'out_day')

ap 'Times'
@@song_list.find({}, {:fields => [:at]}).each do |entry|
  time =  entry["at"].strftime("%H") + ":00"
  @@song_list.update({"_id" => entry["_id"]}, {"$set" => {"time" => time}})
end

map.group_by('time', 'out_time')

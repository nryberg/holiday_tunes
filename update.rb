#!/usr/bin/env  rvm 1.9.3 do ruby

require 'mongo'
require 'awesome_print'
require_relative 'sinatra/Map'
SERVER = '127.0.0.1'
#SERVER = '192.168.0.100'
DATABASE = 'holiday_2012'
SONGS = 'log'
#SONGS = 'song_list'
RENAME = 'rename'
OUTPUT = 'output'
RELATED = ["title", "by", "station"]

@con = Mongo::Connection.new(SERVER)
@@db = @con[DATABASE]
@@song_list = @@db[SONGS]
@@output = @@db[OUTPUT]
@@renamed = @@db[RENAME]

@@db.drop_collection('out_title')
@@db.drop_collection('out_by')
@@db.drop_collection('out_station')

map = Map.new(@@song_list)

ap 'Title'
map.group_by('title', 'out_title')

ap 'By'
map.group_by('by', 'out_by')

ap 'Station'
map.group_by('station', 'out_station')

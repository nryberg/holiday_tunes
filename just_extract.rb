#!/usr/bin/env  rvm 1.9.3 do ruby
require 'yesradio'
require 'awesome_print'
require 'mongo'
require 'mongo'
require 'time'
#SERVER = '127.0.0.1'
#PORT = '27017'
#pwd = 'sffK7mnJ7LWh'
#SERVER ='alex.mongohq.com'
#PORT = '10093'
#SERVER = '192.168.0.100'
#DATABASE = 'holiday_2012'

file = File.new("stations_with_name.txt", "r")
output = File.new("output.txt", "w")

#station = 'KQQL'
#@con = Mongo::Connection.new(SERVER, PORT)
#@@db = @con[DATABASE]
#auth = @@db.authenticate('admin', pwd)
#@@titles = @@db['title']
#@@by = @@db['by']
#@@log = @@db['log']

#@@log.remove()

file.readlines.each do |station_data|
  station = station_data.split(' ')[0]
  ap 'Pulling ' + station
    (1..6).each do |day_num|
    ap "day " + day_num.to_s
    test = Yesradio::get_log :name => station, :ago => day_num.to_s
    test.each do |song|
      outline = Array.new
      outline << station.chomp
      outline << song.title
      outline << Time.parse(song.at.to_s).utc 
      outline << song.by
      outline << song.id

      output.puts outline.join("\t")
    end

  end
end

ap 'Done'

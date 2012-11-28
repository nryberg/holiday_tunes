#!/usr/bin/env  rvm 1.9.3 do ruby
require 'yesradio'
require 'awesome_print'
require 'mongo'
require 'mongo'
require 'time'
SERVER = '127.0.0.1'
#SERVER = '192.168.0.100'
DATABASE = 'holiday_2012'

file = File.new("stations_with_name.txt", "r")
station = 'KQQL'
@con = Mongo::Connection.new(SERVER)
@@db = @con[DATABASE]
@@titles = @@db['title']
@@by = @@db['by']
@@log = @@db['log']

@@log.remove()


file.readlines.each do |station_data|
  station = station_data.split(' ')[0]
  ap 'Pulling ' + station
  (1..5).each do |day_num|
    ap "day " + day_num.to_s
    test = Yesradio::get_log :name => station, :ago => day_num.to_s
    test.each do |song|
      entry = {:station => station.chomp, 
              :title => song.title, 
              :at => Time.parse(song.at.to_s).utc, 
              :by => song.by,
              :song_yes_id => song.id, 
              }

      @@log.save(entry)
  end

  end
end

ap 'Done'

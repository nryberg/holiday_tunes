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

(1..10).each do |x|
  ap x
end
stop

file.readlines.each do |station_data|
  station = station_data.split(' ')[0]
  ap 'Pulling ' + station
  
  test = Yesradio::get_log :name => station, :ago => 6
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

ap 'Done'

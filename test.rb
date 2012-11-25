require 'yesradio'
require 'awesome_print'
require 'mongo'
require 'mongo'
require 'time'
#SERVER = '127.0.0.1'
SERVER = '192.168.0.100'
DATABASE = 'holiday_2012'

station = 'KQQL'
@con = Mongo::Connection.new(SERVER)
@@db = @con[DATABASE]
@@titles = @@db['title']
@@by = @@db['by']
@@log = @@db['log']
test = Yesradio::get_log :name => station, :ago => 6
titles = Array.new
bys = Array.new
test.each do |x|
  titles << x.title
  bys << x.by


end

bys.sort!
bys.uniq!
titles.sort!
titles.uniq!
ap titles[0..5]
ap titles.length

ap bys[0..5]
ap bys.length

ap test[-1]
song = test[-1]
entry = {:station => station.chomp, 
        :title => song.title, 
        :at => Time.parse(song.at.to_s).utc, 
        :by => song.by,
        :song_yes_id => song.id, 
        }

ap @@log.save(entry)

#!/usr/bin/ruby
require 'rubygems'
require "awesome_print"
require 'net/http'
require 'yesradio'
require 'mongo'
require 'time'


@con = Mongo::Connection.new
@db = @con['holiday']
@@songs = @db['song_list']
@out = File.new("output.txt", "w")
@count = 0
fields = @@songs.find_one().keys.join("\t") 
@out.write fields + "\n"

@@songs.find().each do |song|
  @out.write song.values.join("\t") + "\n"
  @count += 1
end

ap @count


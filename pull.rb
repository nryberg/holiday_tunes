#!/usr/bin/ruby
require 'rubygems'
require "awesome_print"
require 'net/http'
require 'yesradio'
require 'mongo'
require 'time'
file = File.new("stations.txt", "r")


@con = Mongo::Connection.new
@db = @con['holiday']
@songs = @db['songs']

file.readlines.each do |station|
  @list = Yesradio::get_log :name => station.chomp, :ago => 1
  ap station.chomp
  @list.each do |song|
    entry = {:station => station.chomp, 
            :title => song.title, 
            :at => Time.parse(song.at.to_s).utc, 
            :by => song.by,
            :cover => song.cover,
            :song_yes_id => song.id
            :rank => song.rank
            }
    
    @songs.save(entry)
  end
end



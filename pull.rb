#!/usr/bin/ruby
#require 'nokogiri'
require 'rubygems'
require "awesome_print"
#require 'net/http'
require 'mechanize'
require 'httparty'
#require 'yesradio'
require 'mongo'
require 'time'
file = File.new("stations.txt", "r")


@con = Mongo::Connection.new('192.168.0.100', 27017)
@db = @con['holiday_2']
@@songs = @db['song_list_2013']

file.readlines.each do |station|
  
  @list = response = HTTParty.get('http://api.yes.com/1/log?name=' + station.chomp) 

 # @list = Yesradio::get_log :name => station.chomp, :ago => 1
  ap station.chomp
  unless @list.nil? 
    @list.each do |song|
      entry = {:station => station.chomp, 
              :title => song.title, 
              :at => Time.parse(song.at.to_s).utc, 
              :by => song.by,
              :cover => song.cover,
              :song_yes_id => song.id, 
              :rank => song.rank
              }
      @@songs.save(entry)
    end
  end
end



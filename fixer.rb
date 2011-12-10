#!/usr/bin/ruby
require 'rubygems'
require "awesome_print"
require 'net/http'
require 'yesradio'
require 'mongo'
require 'time'


@con = Mongo::Connection.new
@db = @con['holiday']
@@songs = @db['song_list'].find({})

@count = 0
@@songs.each do |song|
  if song['at'].day == 8 then
    @db['song_list'].remove({:_id => song["_id"]})
  end
end

ap @count

#!/usr/bin/ruby
require 'rubygems'
require "awesome_print"
require 'mongo'
require 'time'


@con = Mongo::Connection.new('192.168.0.100')
@db = @con['holiday']
@@songs = @db['song_list'].find({})

@count = 0
@@songs.each do |song|
  if song['at'].day == 8 then
    @db['song_list'].remove({:_id => song["_id"]})
  end
end

ap @count

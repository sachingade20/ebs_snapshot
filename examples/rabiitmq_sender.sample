#!/usr/bin/env ruby
# encoding: utf-8
require "bunny"
QUEUE = 'ebs.snapshot'

connection = Bunny.new(:automatically_recover => false)
connection.start
channel = connection.create_channel
queue = channel.queue(QUEUE)
channel.default_exchange.publish("create", :routing_key => queue.name)
puts " [x] Sent 'Create'"
channel.default_exchange.publish("delete", :routing_key => queue.name)
puts " [x] Sent 'Delete'"
connection.close

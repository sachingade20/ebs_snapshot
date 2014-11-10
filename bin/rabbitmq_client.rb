#!/usr/bin/env ruby
# encoding: utf-8
require "bunny"
require_relative '../lib/snapshot'

QUEUE = 'ebs.snapshot'

  conn = Bunny.new(:automatically_recover => false)
  conn.start
  ch = conn.create_channel
  q = ch.queue(QUEUE)

  begin
    puts " [*] Waiting for messages. To exit press CTRL+C"
    q.subscribe(:block => true) do |delivery_info, properties, message_body|
    puts " [x] Received Message  #{message_body}"
    puts "Processing ..."
    if message_body.downcase == 'create'
      create_snapshot
      puts " Snapshot Created... "
    elsif message_body.downcase == 'delete'
      delete_snapshot
      puts " Snapshot Deleted... "
    else
      puts " Invalid request message... \nSupported messages \n1] create \n2] delete"
    end
    puts "Processed ..."
  end

  rescue Interrupt => _
    conn.close
    exit(0)
  end

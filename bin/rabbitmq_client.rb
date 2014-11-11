#!/usr/bin/env ruby
# encoding: utf-8
require 'bunny'
require_relative '../lib/ebs_snapshot'
include EbsSnapshot
# Messaging Queue for triggering snapshot actions
QUEUE = 'ebs.snapshot'

connection = Bunny.new(:automatically_recover => false)
connection.start
channel = connection.create_channel
snapshot_queue = channel.queue(QUEUE)

begin
  puts "Waiting for Snapshot request.."
  $LOG.info("Waiting for Snapshot request..")
  snapshot_queue.subscribe(:block => true) do |delivery_info, properties, message_body|
  $LOG.info("Received request message  Message :: #{message_body}")
  $LOG.info("Processing #{message_body} snapshot now ...")
  # Message :: create
  # creates snapshot using data from config/config.yml file.

  if message_body.downcase == 'create'
    EbsSnapshot.create_snapshot
    $LOG.info("Snapshot Created... ")
  # Message :: delete
  # deletes snapshot using data from config/config.yml file.
  elsif message_body.downcase == 'delete'
    EbsSnapshot.delete_snapshot
    $LOG.info("Snapshot Deleted... ")
  else
    $LOG.error("Invalid request.\n  Supported messages \n    1] create \n    2] delete")
  end
  $LOG.info("#{message_body} snapshot processed ...")
end

rescue Interrupt => _
  connection.close
  exit(0)
end

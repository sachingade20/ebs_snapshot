#!/usr/bin/env ruby

require_relative '../lib/ebs_snapshot'
include EbsSnapshot
# Calls create snapshot
EbsSnapshot.create_snapshot
# Calls delete snapshot
EbsSnapshot.delete_snapshot


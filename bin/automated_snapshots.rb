#!/usr/bin/env ruby
  require 'yaml'

  CONFIG = YAML.load_file('config/config.yml')

  # Create snapshots from instance name
  def run_create_snapshot_from_instance_name
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']
    if CONFIG['instance_name'] != nil
      puts "==> about to run create_from_instance_name #{CONFIG['instance_name']} #{region} "
      %x(rake aws:ebs:snapshot:create_from_instance_name[#{region},#{CONFIG['instance_name']}])
    end

  end

  # Create snapshots from instances
  def run_create_snapshot_from_instances
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']
    if CONFIG['instance_ids'] != nil
      puts "==> about to run create_from_instances #{CONFIG['instance_ids']} #{region} "
      %x(rake aws:ebs:snapshot:create_from_instances[#{region},#{CONFIG['instance_ids']}])
    end

  end

  # Create snapshots from images
  def run_create_snapshot_from_images
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']
    if CONFIG['image_ids'] != nil
      puts "==> about to run create_from_images #{CONFIG['image_ids']} #{region}  "
      %x(rake aws:ebs:snapshot:create_from_images[#{region},#{CONFIG['image_ids']}])
    end
  end

  # Delete snapshots from images
  def run_delete_snapshot_from_images
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']
    age_in_days = get_age_in_days
    if CONFIG['image_ids'] != nil
      puts "==> about to run delete_from_images #{CONFIG['image_ids']} #{age_in_days} #{region} "
      %x(rake aws:ebs:snapshot:delete_from_images[#{region},#{age_in_days},#{CONFIG['image_ids']}])
    end
  end

  # delete snapshots from instances
  def run_delete_snapshot_from_instances
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']
    age_in_days = get_age_in_days
    if CONFIG['instance_ids'] != nil
      puts "==> about to run delete_from_instances #{CONFIG['instance_ids']} #{age_in_days} #{region} "
      %x(rake aws:ebs:snapshot:delete_from_instances[#{region},#{age_in_days},#{CONFIG['instance_ids']}])
    end
  end

  # delete snapshots from instance name
  def run_delete_snapshot_from_instance_name
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']
    age_in_days = get_age_in_days
    if CONFIG['instance_name'] != nil
      puts "==> about to run delete_from_instance_name #{CONFIG['instance_name']} #{age_in_days} #{region} "
      %x(rake aws:ebs:snapshot:delete_from_instance_name[#{region},#{age_in_days},#{CONFIG['instance_name']}])
    end
  end

  def get_age_in_days
    age_in_days = CONFIG['retention']['daily']
    if age_in_days == nil
      periodic_interval = CONFIG['retention']['periodic']['interval']
      periodic_span = CONFIG['retention']['periodic']['span']
      # Calculate age_in_days by multiplying interval and span
      if periodic_interval != nil && periodic_span != nil
        age_in_days = periodic_interval * periodic_span
      end
    end
    # Set default 14 age_in_days if no inputs from user
    if age_in_days == nil
      age_in_days = 14
    end
    age_in_days
  end

  run_create_snapshot_from_instance_name
  run_create_snapshot_from_instances
  run_create_snapshot_from_images
  run_delete_snapshot_from_instances
  run_delete_snapshot_from_images
  run_delete_snapshot_from_instance_name

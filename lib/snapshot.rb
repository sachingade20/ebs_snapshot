#!/usr/bin/env ruby
 require 'yaml'
   CONFIG = YAML::load_file("#{File.expand_path("../../", __FILE__)}/config/config.yml")

  def create_snapshot
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']

    if CONFIG['instance_name'] != nil
      run_create_snapshot_from_instance_name(region, CONFIG['instance_name'])
    end

    if CONFIG['instance_ids'] != nil
      run_create_snapshot_from_instances(region, CONFIG['instance_ids'])
    end

    if CONFIG['image_ids'] != nil
      run_create_snapshot_from_images(region, CONFIG['image_ids'])
    end
  end

  def delete_snapshot
    region = CONFIG['region'] != nil ? CONFIG['region'] : ENV['AWS_REGION']
    age_in_days = CONFIG['retention']['daily']

    if age_in_days == nil
      periodic_interval = CONFIG['retention']['periodic']['interval']
      periodic_span = CONFIG['retention']['periodic']['span']

      # Calculate age_in_days by multiplying interval and span
      if periodic_interval != nil && periodic_span != nil
        age_in_days = periodic_interval * periodic_span
      end
    end

    if CONFIG['instance_name'] != nil
      run_delete_snapshot_from_instance_name(region, CONFIG['instance_name'], age_in_days)
    end

    if CONFIG['instance_ids'] != nil
      run_create_snapshot_from_instances(region, CONFIG['instance_ids'], age_in_days)
    end

    if CONFIG['image_ids'] != nil
      run_create_snapshot_from_images(region, CONFIG['image_ids'], age_in_days)
    end
  end

  # Create snapshots from instance name
  def run_create_snapshot_from_instance_name(region, instance_name)
    if instance_name != nil
      puts "==> about to run create_from_instance_name #{instance_name} #{region} "
      %x(rake aws:ebs:snapshot:create_from_instance_name[#{region},#{instance_name}])
    end
  end

  # Create snapshots from instances
  def run_create_snapshot_from_instances(region, instance_ids)
    if instance_ids != nil
      puts "==> about to run create_from_instances #{instance_ids} #{region} "
      %x(rake aws:ebs:snapshot:create_from_instances[#{region},#{instance_ids}])
    end
  end

  # Create snapshots from images
  def run_create_snapshot_from_images(region, image_ids)
    if image_ids != nil
      puts "==> about to run create_from_images #{image_ids} #{region}  "
      %x(rake aws:ebs:snapshot:create_from_images[#{region},#{image_ids}])
    end
  end

  # Delete snapshots from images
  def run_delete_snapshot_from_images(region, image_ids, age_in_days)
    if image_ids != nil
      puts "==> about to run delete_from_images #{image_ids} #{age_in_days} #{region} "
      %x(rake aws:ebs:snapshot:delete_from_images[#{region},#{age_in_days},#{image_ids}])
    end
  end

  # delete snapshots from instances
  def run_delete_snapshot_from_instances(region, instance_ids, age_in_days)
    if instance_ids != nil
      puts "==> about to run delete_from_instances #{instance_ids} #{age_in_days} #{region} "
      %x(rake aws:ebs:snapshot:delete_from_instances[#{region},#{age_in_days},#{instance_ids}])
    end
  end

  # delete snapshots from instance name
  def run_delete_snapshot_from_instance_name(region, instance_name, age_in_days)
    if instance_name != nil
      puts "==> about to run delete_from_instance_name #{instance_name} #{age_in_days} #{region} "
      %x(rake aws:ebs:snapshot:delete_from_instance_name[#{region},#{age_in_days},#{instance_name}])
    end
  end

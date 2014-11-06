require 'aws-sdk-core'

ROOT_DEVICE = '/dev/sda1'

namespace :aws do

  namespace :ebs do

    namespace :snapshot do

      # Create snapshot of given volume id.
      desc "create"
      task :create, [:volume_id, :description, :region] => [:region] do |t, args|
        create_snapshot(args.volume_id, args.description, args.region)
      end

      # Create snapshot of the volumes attached to the instance id's.
      # instance_id - one or more comma separated instance id's.
      desc "create_from_instances"
      task :create_from_instances, [:region, :instance_id] => [:region] do |t, args|
        instance_ids = args.extras
        instance_ids.push(args.instance_id)
        instance_ids.each { |instance|
          # List all volumes attached to the instance.
          volume_ids = volumes_from_instance(instance, args.region)
          capture_snapshots(volume_ids, args.region)
        }
      end

      # Create snapshots of the volumes attached to the instances of specified name.
      # instance_name - one or more comma separated instance names.
      desc "create_from_instance_name"
      task :create_from_instance_name, [:region, :instance_name] => [:region] do |t, args|
        instance_names = args.extras
        instance_names.push(args.instance_name)

        instance_names.each { |instance_name|
          # List all instances created using the image id.
          instance_ids = instances_from_name(instance_name, args.region)
          instance_ids.each { |instance|
            # List all volumes attached to the instance.
            volume_ids = volumes_from_instance(instance, args.region)
            capture_snapshots(volume_ids, args.region)
          }
        }
      end

      # Create snapshots of the volumes attached to the instances launched using the image id specified.
      # image_id - one or more comma separated image id's.
      desc "create_from_images"
      task :create_from_images, [:region, :image_id] => [:region] do |t, args|
        image_ids = args.extras
        image_ids.push(args.image_id)

        image_ids.each { |image_id|
          # List all instances created using the image id.
          instance_ids = instances_from_ami(image_id, args.region)
          instance_ids.each { |instance|
            # List all volumes attached to the instance.
            volume_ids = volumes_from_instance(instance, args.region)
            capture_snapshots(volume_ids, args.region)
          }
        }
      end

      # Delete snapshot by id.
      desc "delete"
      task :delete, [:snapshot_id, :region] => [:region] do |t, args|
        delete_snapshot(args.snapshot_id, args.region)
      end

      # Delete snapshot by image id.
      # image_id - one or more comma separated image id's.
      desc "delete_from_images"
      task :delete_from_images, [:region, :retention_age_in_days, :image_id] => [:region] do |t, args|
        image_ids = args.extras
        image_ids.push(args.image_id)

        image_ids.each { |image|
          # List all instances matches the image id.
          instance_ids = instances_from_ami(image, args.region)
          instance_ids.each { |instance|
            # List all volumes attached to the instance.
            volume_ids = volumes_from_instance(instance, args.region)
            # Delete snapshots older than retention period.
            delete_snapshots_for_volumes(volume_ids, args.retention_age_in_days, args.region)
          }
        }
      end

      # Delete snapshot by image id.
      # image_id - one or more comma separated image id's.
      desc "delete_from_instance_name"
      task :delete_from_instance_name, [:region, :retention_age_in_days, :instance_name] => [:region] do |t, args|
        instance_names = args.extras
        instance_names.push(args.instance_name)

        instance_names.each { |instance_name|
          # List all instances matches the image id.
          instance_ids = instances_from_name(instance_name, args.region)
          instance_ids.each { |instance|
            # List all volumes attached to the instance.
            volume_ids = volumes_from_instance(instance, args.region)
            # Delete snapshots older than retention period.
            delete_snapshots_for_volumes(volume_ids, args.retention_age_in_days, args.region)
          }
        }
      end

      # Delete snapshots of the volumes attached to the instances launched using the image id specified.
      # instance_id - one or more comma separated instance id's.
      # retention_age_in_days - no of days to retain snapshot.
      desc "delete_from_instances"
      task :delete_from_instances, [:region, :retention_age_in_days, :instance_id] => [:region] do |t, args|
        volume_ids = volumes_from_instance(args.instance_id, args.region)
        # delete snapshots older than retention period
        delete_snapshots_for_volumes(volume_ids, args.retention_age_in_days, args.region)
      end

      # List volumes attached to the instance.
      def volumes_from_instance(instance_id, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.describe_volumes(
          filters:
          [
            {
              name: 'attachment.instance-id',
              values: [instance_id],
            },
          ],
        )

        volume_ids = []
        resp[:volumes].each { |i|
          # Skip root volumes attached to /dev/sda1
          next if i[:attachments][0].device == ROOT_DEVICE
          volume_ids.compact!
          volume_ids.push(i[:volume_id])
          puts "Volume Id: #{i[:volume_id]}\n"
        }
        volume_ids
      end

      # List instances launched using the image id.
      def instances_from_ami(image_id, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.describe_instances(
          filters:
          [
            {
              name: 'image-id',
              values: [image_id],
            },
          ],
        )

        instance_ids = []
        resp[:reservations].each { |r|
          r[:instances].each { |i|
            next unless i[:state][:name] == 'running'
            instance_ids.push(i[:instance_id])
            puts "Instance Id :#{i[:instance_id]}\n"
          }
        }
        instance_ids
      end

      # List instances launched using the image id.
      def instances_from_name(instance_name, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.describe_instances(
          filters:
          [
            {
               name: 'tag-value',
               values: [instance_name]
            }
          ],
        )

        instance_ids = []
        resp[:reservations].each { |r|
          r[:instances].each { |i|
            next unless i[:state][:name] == 'running'
            instance_ids.push(i[:instance_id])
            puts "Instance Id :#{i[:instance_id]}\n"
          }
        }
        instance_ids
      end

      # Capture snapshots.
      def capture_snapshots(volume_ids, region)
        volume_ids.each { |volume|
          name = "#{volume}"
          create_snapshot(volume, name, region)
        }
      end

      # Delete snapshots.
      def delete_snapshots_for_volumes(volume_ids, retention_age_in_days, region)
        volume_ids.each { |volume|
          snapshot_ids = snapshots_for_delete(volume, retention_age_in_days, region)
          snapshot_ids.each { |snapshot|
            delete_snapshot(snapshot, region)
          }
        }
      end

      # List snapshots to delete from specified volume id and retention period.
      def snapshots_for_delete(volumeId, retention_age_in_days, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.describe_snapshots(
          filters:
          [
            {
              name: 'volume-id',
              values: [volumeId],
            },
          ],
        )

        snapshot_ids = []
        resp[:snapshots].each { |i|
          current_time = Time.now
          snapshot_start_time = Time.at(i[:start_time])
          current_age_in_days = (current_time - snapshot_start_time).to_i / (24 * 60 * 60)
          puts "snapshot current age in days :#{current_age_in_days} and retention age days #{retention_age_in_days.to_i} \n"
          # skip snapshot if retention age days is non zero and current age days is less thank retention age days
          next if retention_age_in_days.to_i != 0 && current_age_in_days <= retention_age_in_days.to_i
          snapshot_ids.compact!
          snapshot_ids.push(i[:snapshot_id])
          puts "snapshot Id: #{i[:snapshot_id]}\n"
        }
        snapshot_ids
      end

      # Create snapshot of given volume id.
      def create_snapshot(volume_id, description, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.create_snapshot(
          volume_id: volume_id,
          description: "#{description}-#{Time.now.utc.strftime("%Y-%m-%d.%H%M%S")}",
        )
        puts "Created snapshot #{resp[:snapshot_id]} of volume #{volume_id}"
      end

      # Delete snapshot by id.
      def delete_snapshot(snapshot_id, region)
        ec2 = Aws::EC2::Client.new(region: region)
        resp = ec2.delete_snapshot(
          snapshot_id: snapshot_id,
        )
        puts "Deleted snapshot #{snapshot_id}"
      end

    end

  end

end

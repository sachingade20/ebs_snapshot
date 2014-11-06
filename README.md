# Automate ebs volume snapshots

# Installation
Clone a copy of the main aws-sdk-core-ruby-rake from git repo by running:

    $ git clone git://github.com/brightbytes/aws-sdk-core-ruby-rake.git

And then execute:

    $ bundle

# Configure
Within /config you will find several sample configuration files ending in **.sample**. Simply make copies of these files without the .sample suffix, such as config.yml, and adjust as needed.

# Setup volume filter
Update config/config.yml with the configuration required to find out the volumes for snapshot.

# Setup snapshot scheduler
Update config/schedule.rb to schedule snapshot frequency.

# Setup aws credentials
Configure aws credentials in config/aws_credentials.sh and copy it to home directory

    cp config/aws_credentials.sh.sample ~/aws_credentials.sh
    echo "source ~/aws_credentials.sh" >> ~/.bash_profile

## Usage
Automate ebs volume snapshots on weekly, daily or hourly basis.

# Rake Task User Guide
See `rake -T aws:ebs:snapshot` for available rake tasks.

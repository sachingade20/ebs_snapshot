# Automate ebs volume snapshots

# Installation
Clone a copy of the main ebs-snapshot from git repo by running:

    $ git clone git://github.com/sachingade20/ebs-snapshot.git

And then execute:

    $ bundle

# Configure
Within /config you will find several sample configuration files ending in **.sample**. Simply make copies of these files without the .sample suffix, such as config.yml, and adjust as needed.

# Setup volume filter
Update config/config.yml with the configuration required to find out the volumes for snapshot.

# Setup aws credentials
Configure aws credentials in config/aws_credentials.sh and copy it to home directory

    cp config/aws_credentials.sh.sample ~/aws_credentials.sh
    echo "source ~/aws_credentials.sh" >> ~/.bash_profile

## Usage
Create or Delete ebs volume snapshots.

# Rake Task User Guide
See `rake -T aws:ebs:snapshot` for available rake tasks.

## Clients
Within /bin you will find several clients written for processing snapshot.

Rabbitmq Client
    - Rabbitmq consumer client which triggers snapshot using messages.

        Message Queue : "ebs.snapshot"
        Message Body
            "create" : creates snapshot using configs from config/config.yml.
            "delete" : deletes snapshot using configs from config/config.yml.

Ruby Client
    - Creates and deletes snapshot using configs from config/config.yml.

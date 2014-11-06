require 'highline/import'

namespace :aws do

  def printf_describe(rec, column_width, *keys)
    column = "%-#{column_width}s"
    printf(column * keys.size + "\n", *keys.map(&:to_s).map(&:upcase))
    printf(column * keys.size + "\n", *keys.map { |e| rec[e] } )
  end

  def timestamp_for_name
    Time.now.utc.strftime("%Y-%m-%d-%H-%M-%S") # dots not allowed in some names
  end

  desc "write aws environment credentials"
  task :write_credentials do |t, args|
    path = File.expand_path('~/aws_credentials.sh')
    puts `more #{path}`
    input = ask("Writing your AWS credentials to #{path}. Continue? [y/N]")
    if ['y', 'Y'].include?(input[0])
      File.open(path, 'w') { |f|
        input = ask("Your AWS_ACCESS_KEY_ID ") { |q| q.echo = "x" }
        f.write("export AWS_ACCESS_KEY_ID='#{input.strip}'\n")

        input = ask("Your AWS_SECRET_ACCESS_KEY ") { |q| q.echo = "x" }
        f.write("export AWS_SECRET_ACCESS_KEY='#{input.strip}'\n")

        input = ask("Your AWS Account Id ")
        f.write("export AWS_ACCOUNT_ID='#{input.strip}'\n")

        input = ask("Your AWS_KEYPAIR_NAME ")
        f.write("export AWS_KEYPAIR_NAME='#{input.strip}'\n")

        input = ask("Your AWS_SSH_KEY_PATH ")
        f.write("export AWS_SSH_KEY_PATH='#{input.strip}'\n")

        f.write('# organization definitions')
        input = ask("Your AWS Region ")
        f.write("export AWS_REGION='#{input.strip}'\n")

        input = ask("Your AWS Zone ")
        f.write("export AWS_ZONE='#{input.strip}'\n")
      }
      puts "Successfully wrote the AWS credentials."
      puts "Now add `source #{path}` to your shell rc."
    else
      puts "Process cancelled."
    end
  end

  # hide this: desc "setup env vars for a vagrant up run"
  task :region, [:region] do |t, args|
    args.with_defaults(
      region: ENV['AWS_REGION'],
#      zone: ENV['AWS_ZONE'], # args are not passed to dependent tasks
    )
    Aws.config[:region] = args.region
    puts "\nIn region: #{args.region} ...\n\n"
  end

end

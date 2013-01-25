require 'rake'
require_relative 'services'

desc "Compare files in 2 buckets and download missing from s3 buckets"
task :diff_and_cache_missing do
  env_vars = %w(DEST_BUCKET SRC_BUCKET DEST_REGION SRC_REGION AUTH_KEY AUTH_SECRET)
  missing_env_vars = env_vars.select{ |var| ENV[var].nil? }
  unless missing_env_vars.empty?
    raise "Missing the following env vars: #{missing_env_vars.join(', ')}"
  end

  src = Services::Bucket.new(ENV['SRC_BUCKET'], ENV['SRC_REGION'], ENV['AUTH_KEY'], ENV['AUTH_SECRET'])
  dest = Services::Bucket.new(ENV['DEST_BUCKET'], ENV['DEST_REGION'], ENV['AUTH_KEY'], ENV['AUTH_SECRET'])

  count = 1
  download_count = 0

  target_been_nil = false

  src.files.each do |archived_file|
    filename = src.filename(archived_file.key)

    target = dest.files.get(archived_file.key)
    if not target.nil? and target.persisted?
      print "File##{count}: Exists in destination\n"
    else
      # print free mem if first time here or count on multiple of 20
      if not target_been_nil or count % 20 == 0
        print "#{`free -m`}" unless RUBY_PLATFORM.to_s =~ /darwin/
      end
      target_been_nil = true

      print "File##{count}: Missing from destination\n"

      # cache file from source bucket
      print "- downloading #{filename}..."
      cache_path = src.cache(archived_file)
      print " done!\n"
      download_count += 1

      # process cached file
      # upload to destination
    end

    count += 1
  end
  at_exit {
    print "\nExiting...\n #{count} files listed.\n#{download_count} files downloaded.\n"
  }
end

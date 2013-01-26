require 'fileutils'
require 'fog'

module Services
  class Bucket
    attr_reader :bucket, :region, :endpoint, :provider, :env,
                :auth_key, :auth_secret

    def initialize(bucket, region, auth_key, auth_secret)
      @auth_key = auth_key
      @auth_secret = auth_secret
      @bucket = bucket
      @region = region
      @endpoint = "https://s3-#{region}.amazonaws.com"
      @provider = 'AWS'
    end

    def directory
      @directory ||= connection.directories.get(bucket)
    end

    # delegation
    def files
      directory.files
    end

    def connection
      @connection ||= Fog::Storage.new({
        :provider => 'AWS',
        :aws_access_key_id => auth_key,
        :aws_secret_access_key => auth_secret,
        :region => region,
        :endpoint => endpoint
      })
    end

    def filename(key)
      key.split('/').last
    end

    def cache(key)
      filepath = File.join(cache_dir(key), filename(key))
      @local_file = File.open(filepath, "w+:utf-8:ascii-8bit")
      streamer = lambda do |chunk, remaining, total|
        @local_file.write chunk
      end
      files.get(key, &streamer)
      @local_file.close
      filepath
    end

    def cache_dir(key)
      remote_path = key.gsub("/#{filename(key)}", "")
      cur_dir = File.dirname(File.expand_path(__FILE__))
      dir = File.join(cur_dir, '..', 'tmp', 'downloads', bucket, remote_path)
      FileUtils.mkdir_p(dir) #unless Dir.exists?(dir) # ruby 1.9 only
      dir
    end

    def clear_cache(key)
      filepath = File.join(cache_dir(key), filename(key))
      FileUtils.remove_file(filepath)
      print "Removing #{filepath}\n"
    end
  end
end

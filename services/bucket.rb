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

    def cache(file)
      filepath = File.join(cache_dir(file.key), filename(file.key))
      File.open(filepath, "w+:utf-8:ascii-8bit") do |f|
        f.write file.body
      end
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
      #FileUtils.remove_path(cache_dir(key))
      print "Removing #{cache_dir(key)}\n"
    end
  end
end

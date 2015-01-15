require 'mongo'
require 'rails-perf/build'

# remove build:
# RailsPerf.storage.builds.remove(tag: 'd8e710410ea300ec4626250c0b35946cb52bc38c')

module RailsPerf
  class Storage
    attr_reader :collection

    def initialize
      @client = Mongo::MongoClient.new
      @db = @client[database_name]
      @collection = @db['reports']
    end

    def find_build(id)
      if id.nil?
        raise ArgumentError, "id is blank"
      end

      if id.is_a?(String)
        id = BSON::ObjectId(id)
      end

      found = builds.find_one(_id: id)
      return if found.nil?

      Build.new.unserialize(found)
    end

    class BuildNotFoundError < StandardError;end

    def find_build!(id)
      find_build(id) || raise(BuildNotFoundError, "not found: #{id}")
    end

    def insert_build(build)
      id = builds.insert(build.serialize)
      build.id = id
      build
    end

    def builds
      @db['builds']
    end

    def reports
      @db['reports']
    end

    # def versions
    #   @collection.aggregate([{"$group" => {_id: "$version"}}]).map { |m| m.values.first }.sort
    # end

    def put(hash)
      @collection.insert(hash)
    end

    private

    def database_name
      if ENV["TEST"] || ENV['RACK_ENV'] == 'test'
        'rails-perf-test'
      else
        'rails-perf'
      end
    end
  end

end

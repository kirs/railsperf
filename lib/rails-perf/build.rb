require 'base64'

require 'active_support'
require 'active_support/core_ext/object/blank'

module RailsPerf
  class Build
    attr_accessor :id, :target, :title, :target_url, :global, :tag

    def id=(val)
      @id = val.to_s
    end

    def unserialize(hash)
      tap do |b|
        b.id =              hash["_id"]
        b.target =          hash["target"]
        b.title =           hash["title"]
        b.global =          hash["global"]
        b.tag =             hash["tag"]
      end
    end

    def sequence
      3
    end

    def github_url
      "https://github.com/rails/rails/commit/#{tag}"
    end

    def serialize
      base = {
        target: target,
        title: title,
        tag: tag,
        global: !!global,
      }
      base[:_id] = id if id.present?
      base
    end

    def gemfile_content
      @gemfile_content ||= GemfileBuilder.new.build(target)
    end

    def ==(instance)
      serialize == instance.serialize
    end

    def logger
      @logger ||= Logger.new('log/benchmark.log')
    end

    def ruby_version
      "2.2.0"
    end
  end
end

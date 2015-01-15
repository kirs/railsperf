require 'base64'

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'rails-perf/gemfile_builder'

module RailsPerf
  class Build
    attr_accessor :id, :target, :target_url, :global, :tag, :github_commit

    alias_method :ref, :tag

    def id=(val)
      @id = val.to_s
    end

    def unserialize(hash)
      tap do |b|
        b.id =              hash["_id"]
        b.target =          hash["target"]
        # b.title =           hash["title"]
        b.global =          hash["global"]
        b.tag =             hash["tag"]
        b.github_commit =   hash["github_commit"]
      end
    end

    def title
      # return @title if @title.present?
      return if github_commit.nil?

      github_commit[:commit][:message]
    end

    def commit
      github_commit[:commit]
    end

    def github_commit
      @github_commit ||= begin
        return if tag.blank?

        Octokit.commit('rails/rails', tag)
      end
    end

    def github_url
      "https://github.com/rails/rails/commit/#{tag}"
    end

    def serialize
      base = {
        target: target,
        # title: title,
        tag: tag,
        global: !!global,
        # github_commit: github_commit
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

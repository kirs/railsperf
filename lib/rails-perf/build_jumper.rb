require 'rails-perf/runner'
require 'octokit'

module RailsPerf
  class BuildJumper
    class InvalidRefError < StandardError;end
    attr_reader :build_id

    def initialize(tag)
      @tag = tag.to_s
      if @tag.blank?
        raise ArgumentError, "tag is empty"
      end
    end

    def find_or_create
      # check if tag exists

      tagged = RailsPerf.storage.builds.find_one(tag: @tag)
      if tagged
        @build_id = tagged["_id"].to_s
      else
        unless valid_ref?
          raise InvalidRefError, "ref does not exist"
        end

        build = RailsPerf::Runner.new.execute({
          target: [['rails', { github: 'rails/rails', tag: @tag}]],
          tag: @tag,
          title: commit.message,
          github_commit: commit.to_h
        })
        @build_id = build.id
      end
    end

    private

    def valid_ref?
      github_commit
      true
    rescue Octokit::NotFound
      false
    end

    def github_commit
      @github_commit ||= Octokit.commit('rails/rails', @tag)
    end
  end

end

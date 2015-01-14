require 'erb'
require 'pathname'

require 'active_support'
require 'active_support/core_ext/object/blank'

module RailsPerf
  class GemfileBuilder
    class Renderer
      def initialize(gems)
        @gems = gems
      end

      def render
        ERB.new(template).result(binding)
      end

      private

      def template_path
        Pathname.new(File.dirname(__FILE__)).join("templates", "gemfile.erb")
      end

      def template
        File.open(template_path).read
      end
    end

    class GemRecord < Struct.new(:name, :version_and_source)
      def version_and_source?
        version_and_source.present?
      end
    end

    def build(gems)
      Renderer.new(build_gems(gems)).render
    end

    private

    def build_gems(gems)
      gems.map do |r|
        GemRecord.new.tap { |g|
          g.name = r[0]

          case r[1]
          when Hash
            g.version_and_source = r[1].map { |k, v|
              %{#{k}: "#{v}"}
            }.join(", ")
          when String
            g.version_and_source = %("#{r[1]}")
          end
        }
      end
    end
  end
end

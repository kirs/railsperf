require 'bundler/setup'
require 'sinatra'
require "sinatra/json"
require 'json'
require 'rollbar//middleware/sinatra'
require 'active_support/core_ext/object/blank'

$:.push File.expand_path("../../lib", __FILE__)
require 'rails-perf'
require 'rails-perf/sidekiq'
require 'rails-perf/queries'
require 'rails-perf/report_chart_mapper'
require 'rails-perf/version_range'
require 'rails-perf/build_jumper'
require 'rails-perf/build_status'
require 'rails-perf/gemfile_builder'

set :public_folder, File.dirname(__FILE__) + '/static'

# require_relative './seeds.rb'

use Rollbar::Middleware::Sinatra

before do
  @components = RailsPerf::VersionRange.new.to_a
end

get '/' do
  redirect '/overall'
end

post '/webhook'
  status 200
  ""
end

get '/overall' do
  @current_tab = :overall
  @current_component = @components.first

  raw = RailsPerf::Queries::ComparedReports.new.fetch(@current_component)
  if raw.size.zero?
    redirect '/builds'
    return
  end

  @reports = RailsPerf::ReportChartMapper.new.map(raw)

  erb :global
end

get '/overall/:component' do
  @current_tab = :overall

  if @components.include?(params[:component])
    @current_component = params[:component]
  else
    raise "component does not exist (allowed: #{@components})"
  end

  raw = RailsPerf::Queries::ComparedReports.new.fetch(@current_component)
  @reports = RailsPerf::ReportChartMapper.new.map(raw)

  erb :global
end

get '/builds/:id' do
  @build = RailsPerf.storage.find_build(params[:id])

  if @build.nil?
    raise "no build found"
  end

  @current_component = @components.first

  @build_gemfile = RailsPerf::GemfileBuilder.new.build(@build.target)
  begin
    raw = RailsPerf::Queries::BuildReports.new(@build, @current_component).fetch
    @reports = RailsPerf::ReportChartMapper.new.map(raw)
    erb :build
  rescue RailsPerf::Queries::BuildReports::NotProcessedError
    erb :build_not_ready
  end
end

get '/builds/:id/:component' do
  @build = RailsPerf.storage.find_build(params[:id])

  if @build.nil?
    raise "no build found"
  end

  if @components.include?(params[:component])
    @current_component = params[:component]
  else
    raise "component does not exist (allowed: #{@components})"
  end

  @build_gemfile = RailsPerf::GemfileBuilder.new.build(@build.target)

  begin
    raw = RailsPerf::Queries::BuildReports.new(@build, @current_component).fetch
    @reports = RailsPerf::ReportChartMapper.new.map(raw)
    erb :build
  rescue RailsPerf::Queries::BuildReports::NotProcessedError
    erb :build_not_ready
  end
end

get '/about' do
  @current_tab = :about

  erb :about
end

class BuildRow < Struct.new(:build, :status)
  def gemfile
    RailsPerf::GemfileBuilder.new.build(build.target)
  end
end

get '/builds' do
  @current_tab = :builds

  builds = RailsPerf::Queries::AllBuilds.new.fetch
  @rows = builds.map { |b|
    BuildRow.new(b, RailsPerf::BuildStatus.new(b))
  }

  @jobs_stats = OpenStruct.new
  @jobs_stats.enqueued = Sidekiq::Queue.new.size

  erb :builds
end

post '/builds/jump' do
  jumper = RailsPerf::BuildJumper.new(params[:ref])

  begin
    jumper.find_or_create

    "/builds/#{jumper.build_id}"
  rescue RailsPerf::BuildJumper::InvalidRefError
    status 404
    ""
  end
end

require_relative 'lib/slack_api/methods_spider'
require_relative 'lib/slack_api/events_spider'
require_relative 'lib/slack_api/spec_validator'

namespace :api do
  namespace :events do
    desc 'Handle API events.'
    task :update do
      Rake::Task['api:clean_files'].invoke('events')
      spider = SlackApi::EventsSpider.new(verbose: true, request_interval: 0)
      spider.crawl
      spider.results.each do |result|
        File.open(result[:file_name], 'w+') { |f| f.write(result[:json]) }
      end
    end
    task :validate do
      schema = IO.read('schemas/events.json')
      validator = SlackApi::SpecValidator.new(schema)
      Dir.glob("events/**/*.json").each do |file|
        abort "Invalid file format: #{file}" unless validator.valid?(file)
      end
    end
  end
  namespace :methods do
    desc 'Handle API methods.'
    task :update do
      Rake::Task['api:clean_files'].invoke(%w(groups methods))
      spider = SlackApi::MethodsSpider.new(verbose: true, request_interval: 0)
      spider.crawl
      spider.results.each do |result|
        dir = File.dirname(result[:file_name])
        FileUtils.mkdir(dir) unless Dir.exists?(dir)
        File.open(result[:file_name], 'w+') { |f| f.write(result[:json]) }
      end
    end
    task :validate do
      schema = IO.read('schemas/methods.json')
      validator = SlackApi::SpecValidator.new(schema)
      Dir.glob("methods/**/*.json").each do |file|
        abort "Invalid file format: #{file}" unless validator.valid?(file)
      end
    end
  end
  desc 'Update API.'
  task :update do
    Rake::Task['api:methods:update'].invoke
    Rake::Task['api:events:update'].invoke
    Rake::Task['api:delete_undocumented'].invoke
  end
  task :validate do
    Rake::Task['api:methods:validate'].invoke
    Rake::Task['api:events:validate'].invoke
  end
  desc 'Delete all generated files except undocumented ones.'
  task :clean_files, :dirs do |t, args|
    files = Dir["./{#{Array(args[:dirs]).join(',')}}/*"].grep_v(%r(/undocumented\b))
    FileUtils.rm_rf files
  end
  desc 'Delete any undocumented methods that have since been documented.'
  task :delete_undocumented do
    Dir.glob("**/undocumented/**/*.json").each do |file|
      parent_file = file.gsub 'undocumented/', ''
      next unless File.exists?(parent_file)
      FileUtils.rm file
    end
  end
end

# frozen_string_literal: true

require_relative 'lib/slack_api/base_spider'
require_relative 'lib/slack_api/methods_spider'
require_relative 'lib/slack_api/events_spider'
require_relative 'lib/slack_api/spec_validator'

namespace :api do
  namespace :events do
    desc 'Scrape Slack events, replacing previous results.'
    task :update do
      Rake::Task['api:clean_files'].invoke('events')
      spider = SlackApi::EventsSpider.new(verbose: true, request_interval: 0)
      spider.crawl

      puts "\nRecording #{spider.results.size} events"
      spider.results.each do |result|
        File.write(result[:file_name], result[:json])
      end

      if spider.errors.any?
        puts "\nEncountered #{spider.errors.size} errors!"
        spider.errors.each do |error|
          puts "  #{error[:error]} (#{error[:handler]}, #{error[:url]})\n"
        end
      end

      puts "\nFinished updating events"
    end

    desc 'Validate scraped events are valid.'
    task :validate do
      schema = File.read('schemas/events.json')
      validator = SlackApi::SpecValidator.new(schema)
      Dir.glob('events/**/*.json').each do |file|
        abort "Invalid file format: #{file}" unless validator.valid?(file)
      end
    end
  end

  namespace :methods do
    desc 'Scrape Slack Web API methods, replacing previous results.'
    task :update do
      Rake::Task['api:clean_files'].invoke(%w[groups methods])
      spider = SlackApi::MethodsSpider.new(verbose: true, request_interval: 0)
      spider.crawl

      puts "\nRecording #{spider.results.size} methods"
      spider.results.each do |result|
        dir = File.dirname(result[:file_name])
        FileUtils.mkdir_p(dir)
        File.write(result[:file_name], result[:json])
      end

      if spider.errors.any?
        puts "\nEncountered #{spider.errors.size} errors!"
        spider.errors.each do |error|
          puts "  #{error[:error]} (#{error[:handler]}, #{error[:url]})\n"
        end
      end

      puts "\nFinished updating methods"
    end

    desc 'Validate scraped methods are valid.'
    task :validate do
      schema = File.read('schemas/methods.json')
      validator = SlackApi::SpecValidator.new(schema)
      Dir.glob('methods/**/*.json').each do |file|
        abort "Invalid file format: #{file}" unless validator.valid?(file)
      end
    end
  end

  desc 'Update scraped Slack events and Web API methods.'
  task :update do
    Rake::Task['api:methods:update'].invoke
    Rake::Task['api:events:update'].invoke
    Rake::Task['api:delete_undocumented'].invoke
  end

  desc 'Validate scraped Slack events and Web API methods.'
  task :validate do
    Rake::Task['api:methods:validate'].invoke
    Rake::Task['api:events:validate'].invoke
  end

  desc 'Delete all generated files except undocumented ones.'
  task :clean_files, :dirs do |_t, args|
    files = Dir["./{#{Array(args[:dirs]).join(',')}}/*"].grep_v(%r{/undocumented\b})
    FileUtils.rm_rf files
  end

  desc 'Delete any undocumented methods that have since been documented.'
  task :delete_undocumented do
    Dir.glob('**/undocumented/**/*.json').each do |file|
      parent_file = file.gsub 'undocumented/', ''
      next unless File.exist?(parent_file)

      FileUtils.rm file
    end
  end
end

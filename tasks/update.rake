require_relative 'lib/slack_api/methods_spider'
require_relative 'lib/slack_api/events_spider'

namespace :api do
  namespace :events do
    desc 'Update API events.'
    task :update do
      FileUtils.rm_rf('events')
      FileUtils.mkdir('events')
      spider = SlackApi::EventsSpider.new(verbose: true, request_interval: 0)
      spider.crawl
      spider.results.each do |result|
        File.open(result[:file_name], 'w+') { |f| f.write(result[:json]) }
      end
    end
  end
  namespace :methods do
    desc 'Update API methods.'
    task :update do
      ['groups', 'methods'].each do |dir|
        FileUtils.rm_rf(dir)
        FileUtils.mkdir(dir)
      end
      spider = SlackApi::MethodsSpider.new(verbose: true, request_interval: 0)
      spider.crawl
      spider.results.each do |result|
        dir = File.dirname(result[:file_name])
        FileUtils.mkdir(dir) unless Dir.exists?(dir)
        File.open(result[:file_name], 'w+') { |f| f.write(result[:json]) }
      end
    end
  end
  desc 'Update API.'
  task :update do
    Rake::Task['api:methods:update'].invoke
    Rake::Task['api:events:update'].invoke
  end
end

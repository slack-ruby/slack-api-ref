require_relative 'lib/slack_api/methods_spider'

namespace :api do
  namespace :methods do
    desc 'Update api methods'
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
end

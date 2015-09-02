require_relative 'lib/slack_api/methods_spider'

namespace :api do
  namespace :methods do
    desc 'Update api methods'
    task :update do
      dir = 'methods'
      FileUtils.rm_rf(dir)
      FileUtils.mkdir(dir)
      FileUtils.cd(dir) do
        spider = SlackApi::MethodsSpider.new(verbose: true, request_interval: 0)
        spider.crawl
        spider.results.each do |result|
          File.open(result[:file_name], 'w+') { |f| f.write(result[:json]) }
        end
      end
    end
  end
end

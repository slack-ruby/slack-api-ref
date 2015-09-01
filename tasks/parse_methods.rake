require_relative 'lib/documentation'

namespace :parse do
  namespace :api do
    desc 'Parse api methods'
    task :methods do
      dir = 'methods'
      FileUtils.rm_rf(dir)
      FileUtils.mkdir(dir)
      FileUtils.cd(dir) do
        spider = SlackApiDocumentationSpider.new(verbose: true, request_interval: 0)
        spider.crawl
        spider.results.each do |result|
          File.open(result[:file_name], 'w+') { |f| f.write(result[:json]) }
        end
      end
    end
  end
end

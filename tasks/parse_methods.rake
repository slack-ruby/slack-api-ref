require_relative 'lib/documentation'

namespace :parse do
  namespace :api do
    desc 'Parse api methods'
    task :methods do
      dir = 'methods'
      FileUtils.rm_rf(dir)
      FileUtils.mkdir(dir)
      FileUtils.cd(dir) do
        spider = SlackApiDocumentationSpider.new verbose: true
        spider.crawl
        spider.results.each do |h|
          File.open(h[:file_name], 'w+') { |f| f.write(h[:json]) }
        end
      end
    end
  end
end

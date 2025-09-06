require_relative 'methods_downloader'
require_relative 'events_downloader'

module SlackApi
  module Docs
    class Downloader
      def target_path
        @target_path ||= File.expand_path('../../../docs.slack.dev', __dir__)
      end

      def download!
        methods_downloader.download!
        events_downloader.download!
      end

      private

      def methods_downloader
        @methods_downloader ||= MethodsDownloader.new(target_path)
      end

      def events_downloader
        @events_downloader ||= EventsDownloader.new(target_path)
      end
    end
  end
end

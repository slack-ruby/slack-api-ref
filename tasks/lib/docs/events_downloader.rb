# frozen_string_literal: true

module SlackApi
  module Docs
    class EventsDownloader
      def initialize(target_path)
        @target_path = target_path
      end

      def events_dir
        File.join(@target_path, 'events')
      end

      def events_path
        File.join(events_dir, 'events.json')
      end

      def events_url
        'https://docs.slack.dev/reference/events.json'
      end

      def download!
        puts "#{events_url} => #{events_path}"
        URI.open(events_url) do |file|
          json = JSON.parse(file.read)
          FileUtils.mkdir_p(events_dir)
          File.write(events_path, JSON.pretty_generate(json))
        end
      end
    end
  end
end

module SlackApi
  module Docs
    class Downloader
      def target_path
        @target_path ||= File.expand_path('../../../docs.slack.dev', __dir__)
      end

      def events_dir
        File.join(target_path, 'events')
      end

      def events_path
        File.join(events_dir, 'events.json')
      end

      def methods_dir
        File.join(target_path, 'methods')
      end

      def methods_path
        File.join(methods_dir, 'methods.json')
      end

      def events_url
        'https://docs.slack.dev/reference/events.json'
      end

      def methods_url
        'https://docs.slack.dev/reference/methods.json'
      end

      def method_url(method)
        "https://docs.slack.dev/reference/methods/#{method}.json"
      end

      def method_target_path(method_name)
        File.join(methods_dir, "#{method_name}.json")
      end

      def download!
        download_methods!
        download_events!
      end

      def download_methods!
        puts "#{methods_url} => #{methods_path}"
        FileUtils.mkdir_p(methods_dir)
        URI.open(methods_url) do |file|
          json = JSON.parse(file.read)
          File.write(methods_path, JSON.pretty_generate(json))
          json.each do |method|
            method_name = method['name']
            method_url = method_url(method_name)
            method_target_path = method_target_path(method_name)
            puts "#{method_url} => #{method_target_path}"
            URI.open(method_url) do |method_file|
              method_json = JSON.parse(method_file.read)
              File.write(method_target_path, JSON.pretty_generate(method_json))
            end
          end
        end
      end

      def download_events!
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

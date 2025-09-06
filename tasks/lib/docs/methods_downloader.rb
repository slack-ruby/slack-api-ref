# frozen_string_literal: true

module SlackApi
  module Docs
    class MethodsDownloader
      def initialize(target_path)
        @target_path = target_path
      end

      def methods_dir
        File.join(@target_path, 'methods')
      end

      def methods_path
        File.join(methods_dir, 'methods.json')
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
    end
  end
end

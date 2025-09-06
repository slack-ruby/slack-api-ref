# frozen_string_literal: true

require_relative 'lib/docs/downloader'

namespace :api do
  namespace :ref do
    desc 'Download JSON reference.'
    task :download do
      FileUtils.rm_rf 'docs.slack.dev'
      downloader = SlackApi::Docs::Downloader.new
      downloader.download!
      puts "\nFinished downloading reference."
    end
  end
end

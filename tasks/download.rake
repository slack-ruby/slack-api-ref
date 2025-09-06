# frozen_string_literal: true

require_relative 'lib/docs/downloader'

namespace :api do
  namespace :ref do
    desc 'Download JSON reference.'
    task :download do
      Rake::Task['api:ref:clean_files'].invoke('docs.slack.dev')
      downloader = SlackApi::Docs::Downloader.new
      downloader.download!
      puts "\nFinished downloading reference."
    end

    desc 'Delete all generated files except undocumented ones.'
    task :clean_files, :dirs do |_t, args|
      files = Dir["./{#{Array(args[:dirs]).join(',')}}/*"].grep_v(%r{/undocumented\b})
      FileUtils.rm_rf files
    end
  end
end

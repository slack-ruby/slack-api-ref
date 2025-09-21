require_relative 'lib/slack_api/events_generator'
require_relative 'lib/slack_api/spec_validator'

namespace :api do
  namespace :events do
    desc 'Validate scraped events are valid.'
    task :validate do
      schema = File.read('schemas/events.json')
      validator = SlackApi::SpecValidator.new(schema)
      Dir.glob('events/**/*.json').grep_v(%r{/_patches\b}).each do |file|
        puts file
        abort "Invalid file format: #{file}" unless validator.valid?(file)
      end
    end

    desc 'Update events.'
    task :update do
      # Rake::Task['api:clean_files'].invoke('events')
      SlackApi::EventsGenerator.new.generate!
    end
  end
end

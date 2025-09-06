require_relative 'lib/slack_api/spec_validator'

namespace :api do
  namespace :events do
    desc 'Validate scraped events are valid.'
    task :validate do
      schema = File.read('schemas/events.json')
      validator = SlackApi::SpecValidator.new(schema)
      Dir.glob('events/**/*.json').each do |file|
        abort "Invalid file format: #{file}" unless validator.valid?(file)
      end
    end
  end
end
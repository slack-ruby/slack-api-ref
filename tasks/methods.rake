require_relative 'lib/slack_api/spec_validator'

namespace :api do
  namespace :methods do
    desc 'Validate scraped methods are valid.'
    task :validate do
      schema = File.read('schemas/methods.json')
      validator = SlackApi::SpecValidator.new(schema)
      Dir.glob('methods/**/*.json').grep_v(%r{/_patches\b}).each do |file|
        puts file
        abort "Invalid file format: #{file}" unless validator.valid?(file)
      end
    end
  end
end
